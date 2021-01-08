'''
@date: Jul 18, 2019
@author: IDRIRBSVC
'''

import os
import re
import csv
import json
import time
import yaml
import shutil
import base64
import pymssql
import datetime
import sqlalchemy
from pathlib import Path
import event_trigger
import numpy as np
import pandas as pd
from datetime import datetime as dt
from send_status_email_smtp import send_email

date_str = time.strftime("%Y-%m-%d")
# date_str = '2020-01-20'

#    Global variables
s_host = 'EDW.***REMOVED***.edu'
s_db = 'DWS_PROD'
s_db_md = 'DWS_METADATA'

s_host_clar = 'CLREPIC02.***REMOVED***.edu'
s_db_clar = 'CLARITY'

root_dir = r'\\shandsdfs.***REMOVED***.edu\FILES\SHARE\DSS\IDR_Projects\OMOP'

s_yaml_file = r'\\shandsdfs.***REMOVED***.edu\FILES\SHARE\DSS\IDR_Projects\authsettings\settings.yaml'

excel_consented_anes_providers = 'Consented List - 6-19-18.xlsx'

#    DONE: make these drive agnostic
s_dir_sql = r'{}\sql'.format(root_dir)
intermediary_data_dir = r'{}\intermediary_data\{}'.format(root_dir, date_str)
disclosure_dir = r'{}\disclosure\{}'.format(root_dir, date_str)

# if not os.path.exists(intermediary_data_dir):
#     os.mkdir(intermediary_data_dir)
# if not os.path.exists(disclosure_dir):
#     os.mkdir(disclosure_dir)

Path(intermediary_data_dir).mkdir(parents=True, exist_ok=True) 
Path(disclosure_dir).mkdir(parents=True, exist_ok=True) 

def create_sql_engine(s_host, s_db):
    #    https://stackoverflow.com/questions/40515584/sqlalchemy-df-to-sql-mssql
    return sqlalchemy.create_engine('mssql://%s/%s?driver=SQL+Server+Native+Client+11.0'%(s_host, s_db), pool_recycle=3600)

sa_eng = create_sql_engine(s_host, s_db)
sa_eng_md = create_sql_engine(s_host, s_db_md)


#    Pull propofol metadata from DWS_METADATA to get SQL for each data provider
sql_metadata = """
select *
from DWS_METADATA.dbo.MD_MGMT_WEBI_DATA_PRVDRS_TEST
where DOC_ID in (
    select DOC_ID
    from DWS_METADATA.dbo.MD_MGMT_WEBI_DOCS_TEST
    where DOC_NAME = 'omop'
)"""

propofol_metadata = pd.read_sql(sql_metadata, sa_eng_md)


def get_bo_settings(s_yaml_file, b_bo=True):
    #    Read BO settings from yaml file
    with open(s_yaml_file, "r") as f:
        settings_yaml = f.read()
        bo_settings = yaml.load(settings_yaml)
        f.close()
    
    if b_bo:
        #    Extract login info from BO settings
        username=bo_settings['business_objects']['username']
        password=bo_settings['business_objects']['password']
    else:
        username=bo_settings['dws_prod']['username']
        password=bo_settings['dws_prod']['password']
    return username, password

def read_sql_file(s_dir_sql, s_file_sql):
    with open(os.path.join(s_dir_sql, s_file_sql), 'rU') as f:
        sql = f.read()
    f.close()
    return sql

def get_dws_prod_conn():
    dws_prod = pymssql.connect(
      host='EDW.***REMOVED***.edu',
      database='DWS_PROD'
    )
    return dws_prod

def is_todays_etl_finished():
    #check if the flowsheet ETL is done. If that's done, then everything's done
    query = """
        SELECT CASE WHEN COUNT(1) >= 1 THEN 1 ELSE 0 END ETL_FINISHED
        FROM [DWS_PROD].[dbo].[ALL_LOAD_JOBS_SCHEDULE]
        WHERE 
            convert(date, job_Sched_dt) = convert(date, getdate())
            AND JOB_STATUS = 'D'
            AND JOB_KEY = 283"""
    conn = get_dws_prod_conn()
    return int(pd.read_sql(query, conn).iloc[0].ETL_FINISHED) == 1

def should_we_pause():
    if not is_todays_etl_finished():
        return True
    #backup process begins at 8pm, so pause shortly before then, and 
    #remain paused until at least the beginning of the ETL process (so 
    #we dont wind up in a race condition)
    now = datetime.datetime.now()
    if now.hour < 3 or now.hour >= 19:
        return True
    return False


def convert_float_to_int64(df, column):
    df[column] = df[column].astype(pd.np.int64)
    return df

def convert_numeric_column_to_list(df, column):
    return ','.join([str(x) for x in df[column].unique().tolist()])

def convert_string_column_to_list(df, column):
    return "','".join([str(x) for x in df[column].unique().tolist()])

def pull_sql_from_metadata_table(df, dp_name):
    mask = (df.DP_NAME == dp_name)
    return df.loc[mask, 'SQL_QUERY'].item()

def pull_dimension(s_sql, l_columns):
    df = pd.read_sql(s_sql, sa_eng)
    df.columns = l_columns
    print (df.shape)
    return df

def pull_dimension_replacement(s_sql, l_columns, l_letters,l_search, l_replace, sa_eng=sa_eng):
    for ltr, search, replace in zip(l_letters, l_search, l_replace):
        s_sql = re.sub("@dpvalue\('{}', {}\)".format(ltr, search), r'({})'.format(replace), s_sql)
#     print s_sql
    df = pd.read_sql(s_sql, sa_eng)
    df.columns = l_columns
    print (df.shape)
    return df

def write_to_csv(df, dp_name, encoding='utf-8'):
    df.to_csv(os.path.join(intermediary_data_dir, '{}.tsv'.format(dp_name)), sep='\t', quoting=csv.QUOTE_ALL, index=False, encoding=encoding)
    return

def change_encode(data, cols):
    for col in cols:
        print (col)
        data[col] = data[col].str.decode('utf-8','ignore')
    return data

def pull_data():

    print("Pulling PERSON")
    l_columns = ["Patient Key","Birth Date","Sex","Race","Location ID","Ethnicity","Patient Reported PCP Prov Key"]
    dp_name = 'PERSON'
    omop_person = pull_dimension(pull_sql_from_metadata_table(propofol_metadata, dp_name), l_columns)
    write_to_csv(omop_person, dp_name)

#     print 'Pulling qualifying gi patients'
#     l_columns = ["MRN (UF)","Encounter # (CSN)","Case Date","Service","Surgery Type","Room NAME","Encounter #","Anes 52 Encounter#","OR CASE KEY"]
#     dp_name = 'qualifying gi patients'
#     qualifying_gi_patients = pull_dimension(pull_sql_from_metadata_table(propofol_metadata, dp_name), l_columns)
#     for col in ["Encounter # (CSN)","Encounter #","Anes 52 Encounter#"]:
#         qualifying_gi_patients = convert_float_to_int64(qualifying_gi_patients, col)
#     write_to_csv(qualifying_gi_patients, dp_name)
#     anes_52_encids = convert_numeric_column_to_list(qualifying_gi_patients, 'Anes 52 Encounter#')
#     len(anes_52_encids.split(','))
    
#     print 'Pulling exclusion meds'
#     #        propofol and lidocaine rxnorms share same list of column names
#     l_columns = ["Description Path","Med Code Key"]
#     dp_name = 'exclusion meds'
#     exclusion_meds = pull_dimension(pull_sql_from_metadata_table(propofol_metadata, dp_name), l_columns)
#     exclusion_meds = convert_float_to_int64(exclusion_meds, 'Med Code Key')
#     write_to_csv(exclusion_meds, dp_name)
#     exclusion_med_cd_keys = convert_numeric_column_to_list(exclusion_meds, 'Med Code Key')
#     len(exclusion_med_cd_keys.split(','))
    
#     print 'Pulling propofol rxnorm'
#     dp_name = 'propofol rxnorm'
#     propofol_rxnorm = pull_dimension(pull_sql_from_metadata_table(propofol_metadata, dp_name), l_columns)
#     propofol_rxnorm = convert_float_to_int64(propofol_rxnorm, 'Med Code Key')
#     write_to_csv(propofol_rxnorm, dp_name)
#     propofol_med_cd_keys = convert_numeric_column_to_list(propofol_rxnorm, 'Med Code Key')
#     len(propofol_med_cd_keys.split(','))
    
#     print 'Pulling lidocaine rxnorm'
#     dp_name = 'lidocaine rxnorm'
#     lidocaine_rxnorm = pull_dimension(pull_sql_from_metadata_table(propofol_metadata, dp_name), l_columns)
#     lidocaine_rxnorm = convert_float_to_int64(lidocaine_rxnorm, 'Med Code Key')
#     write_to_csv(lidocaine_rxnorm, dp_name)
#     lidocaine_med_cd_keys = convert_numeric_column_to_list(lidocaine_rxnorm, 'Med Code Key')
#     len(lidocaine_med_cd_keys.split(','))
    
    
#     print 'Pulling or cases with exclusion meds'
#     #        or cases share same list of column names
#     l_columns = ["Med Order Encounter #"]
#     dp_name = 'or cases with exclusion meds'
#     #    DONE: replace in sql file with med_cd_key and anes_52_encid
#     or_cases_with_exclusion_meds = pull_dimension_replacement(pull_sql_from_metadata_table(propofol_metadata, dp_name), 
#                                                                      l_columns, ['N','N'], ['DP2\.DO12f6', 'DP0\.DO19ce'], [exclusion_med_cd_keys, anes_52_encids])
#     or_cases_with_exclusion_meds = convert_float_to_int64(or_cases_with_exclusion_meds, 'Med Order Encounter #')
#     write_to_csv(or_cases_with_exclusion_meds, dp_name)
#     med_order_enc_number_or_cases_excl_meds = convert_numeric_column_to_list(or_cases_with_exclusion_meds, 'Med Order Encounter #')
    
#     print 'Pulling or cases with lidocaine'
#     dp_name = 'or cases with lidocaine'
#     #    DONE: replace in sql file with med_cd_key and anes_52_encid
#     or_cases_with_lidocaine = pull_dimension_replacement(pull_sql_from_metadata_table(propofol_metadata, dp_name), 
#                                                                      l_columns, ['N','N'], ['DP5.DO12f6', 'DP0.DO19ce'], [lidocaine_med_cd_keys, anes_52_encids])
#     or_cases_with_lidocaine = convert_float_to_int64(or_cases_with_lidocaine, 'Med Order Encounter #')
#     write_to_csv(or_cases_with_lidocaine, dp_name)
#     med_order_enc_number_or_cases_lidocaine = convert_numeric_column_to_list(or_cases_with_lidocaine, 'Med Order Encounter #')
    
    
#     print 'Pulling only propofol and lidocaine'
#     l_columns = ["Med Order Encounter #","Encounter # (CSN)"]
#     dp_name = 'only propofol and lidocaine'
#     only_propofol_and_lidocaine = pull_dimension_replacement(pull_sql_from_metadata_table(propofol_metadata, dp_name), 
#                                                                      l_columns, ['N','N','N','N'], ['DP4.DO12f6', 'DP6.DO16cb', 'DP1.DO16cb', 'DP0.DO19ce'], 
#                                                                      [propofol_med_cd_keys, med_order_enc_number_or_cases_lidocaine, med_order_enc_number_or_cases_excl_meds, anes_52_encids])
#     for col in l_columns:
#         only_propofol_and_lidocaine = convert_float_to_int64(only_propofol_and_lidocaine, col)
#     write_to_csv(only_propofol_and_lidocaine, dp_name)
#     med_order_enc_only_propofol_lidocaine = convert_numeric_column_to_list(or_cases_with_lidocaine, 'Med Order Encounter #')
    
    
#     print 'Pulling cohort details'
#     l_columns = ["MRN (UF)","Encounter # (CSN)","EPIC Patient ID","Race","Ethnicity","Case Date","Service","Surgery Type",
#                  "Base Procedure 1","Base Procedure Code 1","CPT 1","CPT 1 Description","Base Procedure 2","Base Procedure Code 2",
#                  "CPT 2","CPT 2 Description","Base Procedure 3","Base Procedure Code 3","CPT 3","CPT 3 Description","Base Procedure 4",
#                  "Base Procedure Code 4","CPT 4","CPT 4 Description","Base Procedure 5","Base Procedure Code 5","CPT 5","CPT 5 Description",
#                  "Base Procedure 6","Base Procedure Code 6","CPT 6","CPT 6 Description","Base Procedure 7","Base Procedure Code 7","CPT 7",
#                  "CPT 7 Description","Base Procedure 8","Base Procedure Code 8","CPT 8","CPT 8 Description","Base Procedure 9",
#                  "Base Procedure Code 9","CPT 9","CPT 9 Description","Base Procedure 10","Base Procedure Code 10","CPT 10",
#                  "CPT 10 Description","Room Start Datetime","Room End Datetime","Anesthesia Start Datetime","Anesthesia Stop Datetime",
#                  "Anes Start Datetime","Anes End Datetime","PACU Enter Datetime","PACU Exit Datetime","Incision Datetime","Dressing Datetime",
#                  "Procedure Start Datetime","Procedure End Datetime","Recovery Start Datetime","Recovery End Datetime","Age at Encounter",
#                  "PACU Type","Admit Date","Dischg Date","OR CASE KEY","Anes 52 Encounter#"]
#     dp_name = 'cohort details'
#     cohort_details = pull_dimension_replacement(pull_sql_from_metadata_table(propofol_metadata, dp_name), 
#                                                                      l_columns, ['N'], ['DP19.DO16cb'], [med_order_enc_only_propofol_lidocaine])
#     for col in ["Encounter # (CSN)","Anes 52 Encounter#"]:
#         cohort_details = convert_float_to_int64(cohort_details, col)
#     write_to_csv(cohort_details, dp_name)
#     or_case_key_cohort_details = convert_numeric_column_to_list(cohort_details, 'OR CASE KEY')
#     epic_ids_cohort_detail = convert_string_column_to_list(cohort_details, 'EPIC Patient ID')
#     mrn_uf_cohort_detail = convert_numeric_column_to_list(cohort_details, 'MRN (UF)')
#     enc_csn_cohort_detail = convert_numeric_column_to_list(cohort_details, 'Encounter # (CSN)')
    
    
#     print 'Reading in consented anes providers'
#     consented_anes_providers = pd.read_excel(os.path.join(root_dir, excel_consented_anes_providers), sheet_name='Sheet1')
#     consented_anes_providers.shape
#     names_consented_anes_providers = convert_string_column_to_list(consented_anes_providers, 'Full Name (From WEBI - manually adjudicated)')
#     write_to_csv(consented_anes_providers, 'consented anes providers')
    
#     print 'Pulling case anes staff'
#     #    TODO: figure out why getting more OR case staff - 2535 vs 2300 from historic data
#     l_columns = ["OR CASE KEY","Staff Role","Staff Name","Staff Service","Role Type"]
#     dp_name = 'case anes staff'
#     s_sql = read_sql_file(s_dir_sql, 'case anes staff modified.sql')
#     s_sql = re.sub('XXOR_CASE_KEYXX', or_case_key_cohort_details, s_sql)
#     s_sql = re.sub('XXNAMESXX', "'{}'".format(names_consented_anes_providers), s_sql)
#     case_anes_staff = pull_dimension(s_sql, l_columns)
#     case_anes_staff.drop_duplicates(inplace=True)
#     write_to_csv(case_anes_staff, dp_name)
    
    
#     print 'Pulling propofol admin details'
#     l_columns = ["MRN (UF)","Encounter # (CSN)","Med Order Encounter #","Patient Name","Med Order Datetime",
#                  "Med Order Desc","Med Order Display Name","Taken Datetime","MAR Action","Med Infusion Rate",
#                  "Med Infusion Rate Unit Desc","Total Dose (character)","Med Dose Unit Desc","Med Strength",
#                  "Med Name","Med Simple Generic Name","Med Form","Med Route","MAR Line #"]
#     dp_name = 'propofol admin details'
#     propofol_admin_details = pull_dimension_replacement(pull_sql_from_metadata_table(propofol_metadata, dp_name), 
#                                                                      l_columns, ['N', 'N'], ['DP4.DO12f6','DP19.DO16cb'], 
#                                                                      [propofol_med_cd_keys, med_order_enc_only_propofol_lidocaine])
#     for col in ["Encounter # (CSN)","Med Order Encounter #"]:
#         propofol_admin_details = convert_float_to_int64(propofol_admin_details, col)
#     write_to_csv(propofol_admin_details, dp_name)
    
#     print 'Pull lidocaine admin details'
#     #    TODO: figure why using SQL file returns empty df; also why no SQL gets pulled from BO CMS...?
#     dp_name = 'lidocaine admin details'
# #     lidocaine_admin_details = pull_dimension_replacement(read_sql_file(s_dir_sql, 'lidocaine admin details.sql'), 
# #                                                                      l_columns,  ['N', 'N'],['DP5.DO12f6','DP19.DO16cb'], 
# #                                                                      [lidocaine_med_cd_keys, med_order_enc_only_propofol_lidocaine])
#     lidocaine_admin_details = pull_dimension_replacement(pull_sql_from_metadata_table(propofol_metadata, 'propofol admin details'), 
#                                                                      l_columns, ['N', 'N'], ['DP4.DO12f6','DP19.DO16cb'], 
#                                                                      [lidocaine_med_cd_keys, med_order_enc_only_propofol_lidocaine])
#     for col in ["Encounter # (CSN)","Med Order Encounter #"]:
#         lidocaine_admin_details = convert_float_to_int64(lidocaine_admin_details, col)
#     write_to_csv(lidocaine_admin_details, dp_name)
    
    
#     print 'Pulling height and weight'
#     l_columns = ["MRN (UF)","Height & Weight Datetime","Height (cm)","Weight (kgs)"]
#     dp_name = 'height and weight'
#     height_and_weight = pull_dimension_replacement(pull_sql_from_metadata_table(propofol_metadata, dp_name), 
#                                                                      l_columns, ['A'], ['DP8.DOec7'], 
#                                                                      ["'{}'".format(epic_ids_cohort_detail)])
#     write_to_csv(height_and_weight, dp_name)
    
#     print 'Pulling BMI'
#     l_columns = ["MRN (UF)","Height & Weight Datetime","BMI Calc from HtWt Collected"]
#     dp_name = 'bmi 1'
#     bmi_1 = pull_dimension_replacement(pull_sql_from_metadata_table(propofol_metadata, dp_name), l_columns,
#                                                                       ['A'], ['DP8.DOec7'], ["'{}'".format(epic_ids_cohort_detail)])
#     write_to_csv(bmi_1, dp_name)
    
#     l_columns = ["MRN (UF)","Stamped BMI on Flowsheet Datetime","Stamped BMI on Flowsheet"]
#     dp_name = 'bmi 2'
#     bmi_2 = pull_dimension_replacement(pull_sql_from_metadata_table(propofol_metadata, dp_name), l_columns,
#                                                                       ['A'], ['DP8.DOec7'], ["'{}'".format(epic_ids_cohort_detail)])
#     write_to_csv(bmi_2, dp_name)
    
#     l_columns = ["MRN (UF)","Last Stamped BMI on Encounter Datetime","Last Stamped BMI on Encounter"]
#     dp_name = 'bmi 3'
#     bmi_3 = pull_dimension_replacement(pull_sql_from_metadata_table(propofol_metadata, dp_name), l_columns,
#                                                                       ['A'], ['DP8.DOec7'], ["'{}'".format(epic_ids_cohort_detail)])
#     write_to_csv(bmi_3, dp_name)
    
#     print 'Pulling aldrete scores'
#     #    DONE: connect to Clarity to pull data
#     username, password = get_bo_settings(s_yaml_file)
#     sa_eng_clrty = sqlalchemy.create_engine('mssql://' + base64.b64decode(username) + ':' + base64.b64decode(password) + '@' + s_host_clar + '/' + s_db_clar + '?driver=SQL+Server+Native+Client+11.0', pool_recycle=3600)
#     l_columns = ["Pat Id","Disp Name","Recorded Time","Meas Value","Recorded Date"]
#     dp_name = 'aldrete scores'
#     aldrete_scores = pull_dimension_replacement(pull_sql_from_metadata_table(propofol_metadata, dp_name), l_columns,
#                                                                       ['A'], ['DP8.DOec7'], ["'{}'".format(epic_ids_cohort_detail)],
#                                                                       sa_eng_clrty)
#     write_to_csv(aldrete_scores, dp_name)
    
#     print 'Pulling vitals'
#     l_columns = ["MRN (UF)","Encounter # (CSN)","Observation Datetime","Heart Rate","Respiratory Rate","BP Non-Invasive","BP","BP Method","SPO2","ETCO2"]
#     dp_name = 'vitals'
#     vitals = pull_dimension_replacement(pull_sql_from_metadata_table(propofol_metadata, dp_name), l_columns,
#                                                                       ['N'], ['DP8.DOdb0'], [enc_csn_cohort_detail])
#     write_to_csv(vitals, dp_name)
    
    
    
#     print 'Pulling DX'
#     #    Pull diag hx hosp icd10
#     l_columns = ["MRN (UF)","ICD10 50-Diagnosis Decimal","ICD10 50-Diagnoses Desc","Dischg Date"]
#     dp_name = 'diag hx hosp icd10'
#     diag_hx_hosp_icd10 = pull_dimension_replacement(pull_sql_from_metadata_table(propofol_metadata, dp_name), l_columns,
#                                                                       ['N'], ['DP8.DOb2e'], [mrn_uf_cohort_detail])
#     write_to_csv(diag_hx_hosp_icd10, dp_name)
    
#     #    Pull diag hx hosp icd9
#     l_columns = ["MRN (UF)","ICD9 50-Diagnosis Decimal","ICD9 50-Diagnoses Desc","Dischg Date"]
#     dp_name = 'diag hx hosp icd9'
#     diag_hx_hosp_icd9 = pull_dimension_replacement(pull_sql_from_metadata_table(propofol_metadata, dp_name), l_columns,
#                                                                       ['N'], ['DP8.DOb2e'], [mrn_uf_cohort_detail])
#     write_to_csv(diag_hx_hosp_icd9, dp_name)
    
#     #    Pull diag hx pro billing
#     l_columns = ["MRN (UF)","Date of Service","DX Code 1","DX Code 1 Description","DX Code 1 Type","DX Code 2",
#                  "DX Code 2 Description","DX Code 2 Type","DX Code 3","DX Code 3 Description","Dx Code 3 Type",
#                  "DX Code 4","DX Code 4 Description","DX Code 4 Type","DX Code 5","DX Code 5 Description",
#                  "DX Code 5 Type","DX Code 6","DX Code 6 Description","DX Code 6 Type","# of Unique Patients"]
#     dp_name = 'diag hx pro billing'
#     diag_hx_pro_billing = pull_dimension_replacement(pull_sql_from_metadata_table(propofol_metadata, dp_name), l_columns,
#                                                                       ['N'], ['DP8.DOb2e'], [mrn_uf_cohort_detail])
#     #    TODO: fix error
#     #        UnicodeEncodeError: 'ascii' codec can't encode characters in position 1-2: ordinal not in range(128)
#     write_to_csv(diag_hx_pro_billing, dp_name, encoding='utf-8')
    
#     #    Pull diag hx problem list clinenc
#     l_columns = ["MRN (UF)","Noted Date","Resolved Date","Entry Date","ICD Type","Dx Desc","Dx Code"]
#     dp_name = 'diag hx problem list clinenc'
#     diag_hx_problem_list_clinenc = pull_dimension_replacement(pull_sql_from_metadata_table(propofol_metadata, dp_name), l_columns,
#                                                                       ['N'], ['DP8.DOb2e'], [mrn_uf_cohort_detail])
#     write_to_csv(diag_hx_problem_list_clinenc, dp_name)
    
def main():
    #    DONE: insert pause criteria
    while should_we_pause():
        print("Pausing execution.")
        time.sleep(600)
        
    pull_data()
    
    event_trigger.trigger_event("raw data downloaded")
    return

if __name__ == '__main__':
    stime = dt.now()
    print ('Start time: {}\r\n'.format(stime))
    main()
    print ('Finished at: {}'.format(dt.now()))
    print ('Total processing time (h:m:s): {}\r\n'.format(dt.now() - stime))
    pass


