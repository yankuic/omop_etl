"""[description]."""

import sys
import os
import pandas as pd
from pathlib import Path
import sqlalchemy
from omop_etl.datastore import DataStore
from datetime import datetime as dt

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
        'order': 'DRUG_ADMIN', 
        'admin': 'DRUG_ORDER'
    },
    'measurement': {
        'bp': 'MEASUREMENT_BP',
        'heart_rate': 'MEASUREMENT_HeartRate',
        'lab': 'MEASUREMENT_Lab',
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
        'zipcode': 'OBSERVATION_Zipcode'
    }
}

#   Utils   #

# def index_containing_substring(the_list, substring):
#     for i, s in enumerate(the_list):
#         if substring in s:
#               return i

#   Global variables   #
# print(os.getcwd())
# main_path = os.path.dirname(os.path.abspath(__file__))
cur_path = 'omop_etl/pullrawdata' # os.path.dirname(__file__)
# config_path = os.path.join(cur_path,'input_config.txt')
now = dt.now()
now_dt =  now.strftime("%m/%d/%Y %H:%M:%S")

# with open(config_path,'r') as input_config:
#     all_data = [line.strip() for line in input_config.readlines()]
    # wh_host = str(all_data[index_containing_substring(all_data, 'wh_host')]).split('=')[1].strip()
    # mtdt_db = str(all_data[index_containing_substring(all_data, 'mtdt_db')]).split('=')[1].strip()
    # omop_db = str(all_data[index_containing_substring(all_data, 'omop_db')]).split('=')[1].strip()
    # dp_names = all_data[index_containing_substring(all_data, 'dp_name')].split('=')[1]
    # dp_list = dp_names.strip().split(', ') 
    # start_date = str(all_data[index_containing_substring(all_data, 'start_date')]).split('=')[1].strip()
    # end_date = str(all_data[index_containing_substring(all_data, 'end_date')]).split('=')[1].strip()
    # patient_id_path = str(all_data[index_containing_substring(all_data, 'patient_file')]).split('=')[1].strip()
    # _patient_id = pd.read_csv(os.path.join(cur_path,patient_id_path), dtype ={'id':'str'} )


#   Derived variables   #
#You can declare all these variables within your class (if you really want to use a class)
#that way you only need to pass config.yml as parameter to instantiate. 
# mtdt_db = 'mtd'
mtd_eng = DataStore('config.yml', store_name='mtd').engine

# omop_db = 'omop'
store = DataStore('config.yml')
omop_eng = store.engine

start_date = store.config_param['date_range']['start_date']
end_date = store.config_param['date_range']['end_date']
# #Patient file is now read from DWS_OMOP.cohort.PersonList
# patient_file = store.config_param['patient_file']
# _patient_id = pd.read_csv(os.path.join(cur_path, patient_file), dtype ={'id':'str'} )
# patient_id = _patient_id['id'].astype(str).tolist()
# patient_id = ','.join(patient_id)


# Get list of tables to stage
load_params = store.config_param['load']

dp_list = []
for t in load_params.keys():
    if load_params[t]:
        for part in load_params[t].keys(): 
            dp_list.append(STAGE[t][part])
    else: 
        dp_list.append(STAGE[t])

now = dt.now()
now_dt =  now.strftime("%m/%d/%Y %H:%M:%S")
if len(end_date) == 0:
    end_date = now_dt


class Puller:
    
    def __init__(self, dp_name, mtd_eng, omop_eng):
        self.dp_name = dp_name
        self.mtd_eng = mtd_eng
        self.omop_eng = omop_eng
        
    ################################################
    #   Read and execute SQL query from metadata   #
    ################################################

    #lets avoid this name (I have an execute method but basically does the same as the execute method from sqlalchemy)
    #my suggestion is to rename to run. 
    def execute(self):
        
        # Matt will update the table to generate the sql that queries DWS in BO.
        sql_metadata = """
        select DISTINCT DP_NAME, SQL_QUERY
        from DWS_METADATA.dbo.MD_MGMT_WEBI_DATA_PRVDRS
        where DOC_ID in (
            select DOC_ID
            from DWS_METADATA.dbo.MD_MGMT_WEBI_DOCS 
            where DOC_NAME = 'omop'
        )
        """
        # DOC_NAME = 'omop' (this will be different for each project)

        # Read out the SQL query and put in a dataframe
        omop_metadata = pd.read_sql(sql_metadata, self.mtd_eng)
        sql_query = omop_metadata.loc[omop_metadata.DP_NAME == self.dp_name, 'SQL_QUERY'].item()


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
        
        '''.format(self.dp_name,sql_query)

        # # datastore = DataStore('omop')
        # row_count = store.row_count(self.dp_name, 'stage')
        # query_log = """
        # values (''{0}'', ''{1}'', {2}, {3})
        # """.format(self.dp_name, sql_query, now_dt, row_count)


        # log_sp = '''
        # insert into [DWS_OMOP].[stage].[query_log] with (tablock)
        # {}
        # '''.format(query_log)

        #################################
        #   Exexcute Stored Procedure   #
        #################################

        execute_sp = "execute ('use [DWS_PROD]; {}')".format(create_sp)

        con = self.omop_eng.connect()
        con.execute(execute_sp)
        tran_con = con.begin()
        tran_con.commit()

        # execute_sp = "execute ('use [DWS_PROD]; {}')".format(log_sp)

        # con = self.omop_eng.connect()
        # con.execute(execute_sp)
        # tran_con = con.begin()
        # tran_con.commit()


if __name__ == '__main__':
    stime = dt.now()
    print ('Start time: {}\r\n'.format(stime))
    for dp in dp_list:
        Puller(dp, mtd_eng, omop_eng).execute()
        print("The stage tables has been successfully created")
    print ('Finished at: {}'.format(dt.now()))
    print ('Total processing time (h:m:s): {}\r\n'.format(dt.now() - stime))
    