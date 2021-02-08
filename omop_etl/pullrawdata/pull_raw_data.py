"""[description]."""

import sys
import os
import pandas as pd
from pathlib import Path
import sqlalchemy
from omop_etl.datastore import DataStore
from datetime import datetime as dt

# PARAMETERS:

STAGE = {
    'person': 'PERSON',
    'death': 'DEATH',
    'condition_occurrence': 'CONDITION',
    'visit': 'VISIT',
    'procedure_occurrence': {
        'cpt': 'PROCEDURE_CPT',
        'icd': 'PROCEDURE_ICD'
    },
    'drug_exposure': {
        'order': 'DRUG_ORDER', 
        'admin': 'DRUG_ADMIN'
    },
    'measurement': {
        'bp': 'MEASUREMENT_BP',
        'heart_rate': 'MEASUREMENT_HeartRate',
        'lab': 'MEASUREMENT_LAB',
        'lda': 'MEASUREMENT_LDA',
        'pain': 'MEASUREMENT_PainScale',
        'qtcb': 'MEASUREMENT_QTCB',
        'rothman': 'MEASUREMENT_Rothman',
        'sofa': 'MEASUREMENT_SOFA',
        'temp': 'MEASUREMENT_Temp',
        'weight': 'MEASUREMENT_Weight',
        'height': 'MEASUREMENT_Height',
        'res_dev': 'MEASUREMENT_Res_Device',
        'res_etco2': 'MEASUREMENT_Res_ETCO2', 
        'res_fio2': 'MEASUREMENT_Res_FIO2',
        'res_gcs': 'MEASUREMENT_Res_GCS',
        'res_o2': 'MEASUREMENT_Res_O2',
        'res_peep': 'MEASUREMENT_Res_PEEP',
        'res_pip': 'MEASUREMENT_Res_PIP',
        'res_resp': 'MEASUREMENT_Res_RESP',
        'res_spo2': 'MEASUREMENT_Res_SPO2',
        'res_tidal': 'MEASUREMENT_Res_Tidal',
        'res_vent': 'MEASUREMENT_Res_Vent'
    },
    'observation': {
        'icu': 'OBSERVATION_ICU',
        'payer': 'OBSERVATION_Payer',
        'smoking': 'OBSERVATION_Smoking',
        'zipcode': 'OBSERVATION_Zipcode',
        'vent': 'OBSERVATION_Vent',
        'lda': 'OBSERVATION_LDA',
    }
}


################################################
#   Read and execute SQL query from metadata   #
################################################

#lets avoid this name (I have an execute method but basically does the same as the execute method from sqlalchemy)
#my suggestion is to rename to run. 
def pull_raw(dp_name, mtd_eng, omop_eng):
    
    # Matt will update the table to generate the sql that queries DWS in BO.
    sql_metadata = """
    select *
    from DWS_METADATA.dbo.MD_MGMT_WEBI_DATA_PRVDRS
    where DOC_ID in (
        select DOC_ID
        from DWS_METADATA.dbo.MD_MGMT_WEBI_DOCS 
        where DOC_NAME = 'omop' and FOLDER_PATH like 'Public Folders%'
    )
    """
    # DOC_NAME = 'omop' (this will be different for each project)

    # Read out the SQL query and put in a dataframe
    omop_metadata = pd.read_sql(sql_metadata, mtd_eng)
    sql_query = omop_metadata.loc[omop_metadata.DP_NAME == dp_name, 'SQL_QUERY'].item()


    #############################
    #   Create Stored Procedure #
    #############################

    patient_id = "select PATIENT_KEY from [DWS_OMOP].cohort.PersonList"
    sql_query = sql_query.replace("12345678", patient_id)
    sql_query = sql_query.replace("01/01/1900 00:0:0", start_date)
    sql_query = sql_query.replace("12/31/1900 00:0:0", end_date)
    sql_query = sql_query.replace("'","''")

    create_sp = '''
    truncate table [DWS_OMOP].[stage].[{0}]
    insert into [DWS_OMOP].[stage].[{0}] with (tablock)
    {1} 
    
    '''.format(dp_name,sql_query)

    ds = DataStore('config.yml')
    row_count = ds.row_count(dp_name, 'stage')

    #################################
    #   Exexcute Stored Procedure   #
    #################################

    execute_sp = "execute ('use [DWS_PROD]; {}')".format(create_sp)

    con = omop_eng.connect()
    con.execute(execute_sp)
    tran_con = con.begin()
    tran_con.commit()
    con.close()

    return  sql_query, row_count

    # execute_sp = "execute ('use [DWS_PROD]; {}')".format(log_sp)

    # con = self.omop_eng.connect()
    # con.execute(execute_sp)
    # tran_con = con.begin()
    # tran_con.commit()

def log(omop_eng, dp, sql_query, rows, start_dt, end_dt):

    diff = end_dt - start_dt
    ELAPSED_TIME = str(diff)
    
    #sql_query = sql_query.replace("''","'")

    query = """SELECT
    SCHEMA_NAME(SCHEMA_ID) AS SCHEMA_NAME,
	NAME AS TABLE_NAME,
	CREATE_DATE,
	MODIFY_DATE
    from SYS.TABLES
    WHERE SCHEMA_NAME(SCHEMA_ID) = 'STAGE' 
	ORDER BY MODIFY_DATE DESC
    """
    # DOC_NAME = 'omop' (this will be different for each project)

    # Read out the SQL query and put in a dataframe
    query_log = pd.read_sql(query, omop_eng)
    SCHEMA_NAME = query_log.loc[query_log.TABLE_NAME.str.upper() == dp.upper(), 'SCHEMA_NAME'].item()
    CREATE_DATE = query_log.loc[query_log.TABLE_NAME.str.upper() == dp.upper(), 'CREATE_DATE'].item()
    MODIFY_DATE = query_log.loc[query_log.TABLE_NAME.str.upper() == dp.upper(), 'MODIFY_DATE'].item()

    REFRESH_DATE = dt.now()
    REFRESH_DATE.strftime("%m/%d/%Y %H:%M:%S")

    insert_query = """
    VALUES ("{0}",
        "{1}",
        "{2}",
        {3},
        "{4}",
        "{5}",
        "{6}",
        "{7}"
    )
    """.format(SCHEMA_NAME, dp, sql_query, rows, REFRESH_DATE, MODIFY_DATE, ELAPSED_TIME, CREATE_DATE)

    log_query = """
    SET QUOTED_IDENTIFIER OFF
    SET ANSI_NULLS ON
    insert into [DWS_OMOP].[stage].[query_log] with (tablock)
    {}
    """.format(insert_query)

    execute_sp = "execute ('use [DWS_OMOP]; {}')".format(log_query)

    con = omop_eng.connect()
    con.execute(execute_sp)
    tran_con = con.begin()
    tran_con.commit()
    con.close()

if __name__ == '__main__':
    #cur_path = 'omop_etl/pullrawdata' # os.path.dirname(__file__)

    mtd_eng = DataStore('config.yml', store_name='mtd').engine

    store = DataStore('config.yml')
    omop_eng = store.engine

    # Get start and end dates from the configuration file
    start_date = store.config_param['date_range']['start_date']
    end_date = store.config_param['date_range']['end_date']
    now = dt.now()
    now_dt =  now.strftime("%m/%d/%Y %H:%M:%S")
    if len(end_date) == 0:
        end_date = now_dt

    # Get list of tables to stage from the configuration file
    load_params = store.config_param['load']

    dp_list = []
    for t in load_params.keys():
        if load_params[t]:
            for part in load_params[t].keys(): 
                dp_list.append(STAGE[t][part])
        else: 
            dp_list.append(STAGE[t])

    running_start_dt = dt.now()
    # overall_start_dt =  overall_start_dt.strftime("%m/%d/%Y %H:%M:%S")
  
    print('Start time: {}'.format(now_dt))
    for dp in dp_list:
        table_start_dt = dt.now()
        sql_query, rows = pull_raw(dp, mtd_eng, omop_eng)
        table_end_dt = dt.now()
        log(omop_eng, dp, sql_query, rows, table_start_dt, table_end_dt)
        print("The {} stage table has been successfully created with {} rows!".format(dp, rows))
    running_end_dt = dt.now()
    # overall_end_dt =  overall_start_dt.strftime("%m/%d/%Y %H:%M:%S")
    print ('Finished at: {}'.format(running_end_dt))
    duration = str(running_end_dt - running_start_dt)
    print ('The duration is: {}\r\n'.format(duration))
    