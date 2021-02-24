"""[description]."""

# import sys
# import os
from datetime import datetime as dt
import logging
import yaml
import sqlparse
import pandas as pd
# from pathlib import Path
# import sqlalchemy
# PARAMETERS:
from omop_etl.datastore import DataStore, format_bo_sql
from omop_etl.utils import timeitd

STAGE = {
    'person': 'PERSON',
    'death': 'DEATH',
    'visit_occurrence': 'VISIT',
    'condition_occurrence': 'CONDITION',
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

class Stager:
    def __init__(self, config_file):  
        with open('omop_etl/stage_config.yml') as f:
            yml = yaml.safe_load(f)

        self.store = DataStore(config_file)
        self.aliases = yml['aliases']
        self.bo_queries = self.store.get_bo_query('omop')
        self.start_date = self.store.config_param['date_range']['start_date']
        self.end_date = self.store.config_param['date_range']['end_date']

    def gen_stage_query(self, table, subset=None):
        """Generate stage query from BO."""
    #     #############################
    #     #   Create Stored Procedure #
    #     #############################
        assert table in STAGE.keys(), f'{table} is not a valid table name.'
        
        if subset: 
            assert subset in STAGE[table].keys(), f'{subset} is not a valid subset for {table}.'
            dp_name = STAGE[table][subset]
        else: 
            dp_name = STAGE[table]

        col_aliases= self.aliases[dp_name]

        sql_query = format_bo_sql(self.bo_queries[dp_name], dp_name, schema='stage', aliases=col_aliases)
        patient_id = "select PATIENT_KEY from DWS_OMOP.cohort.PersonList"
        sql_query = sql_query.replace("12345678", patient_id)
        sql_query = sql_query.replace("01/01/1900 00:0:0", self.start_date)
        sql_query = sql_query.replace("12/31/1900 00:0:0", self.end_date)

        sql_query = sqlparse.format(sql_query, reindent_aligned=True, indent_with=1)

        return f"EXECUTE ('USE DWS_PROD;\n {sql_query}')" 

    #################################
    #   Exexcute Stored Procedure   #
    #################################

    @timeitd
    def stage_table(self, table, subset=None):
        """Execute stage bo query."""
        logging.info(f'Process to execute stage_table({table}, {subset}) is started.')

        execute_sp = self.gen_stage_query(table, subset)
        return self.store.execute(execute_sp)

        # execute_sp = "execute ('use [DWS_PROD]; {}')".format(log_sp)

        # con = self.omop_eng.connect()
        # con.execute(execute_sp)
        # tran_con = con.begin()
        # tran_con.commit()
    
def log(dp, sql_query, rows):

    start_date = store.config_param['date_range']['start_date']
    end_date = store.config_param['date_range']['end_date']
    now = dt.now()
    now_dt =  now.strftime("%m/%d/%Y %H:%M:%S")
    if len(end_date) == 0:
        end_date = now_dt

    diff = end_date - start_date
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
    with store.connection() as con:
        query_log = pd.read_sql(query, con)
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

    return store.execute(execute_sp)

# if __name__ == '__main__':
#     #cur_path = 'omop_etl/pullrawdata' # os.path.dirname(__file__)

#     # mtd_eng = DataStore('config.yml', store_name='mtd').engine

#     # store = DataStore('config.yml')
#     # omop_eng = store.engine

#     # Get start and end dates from the configuration file
    
#     # Get list of tables to stage from the configuration file
#     # load_params = store.config_param['load']

#     dp_list = []
#     for t in store.load_params.keys():
#         if store.load_params[t]:
#             for part in store.load_params[t].keys(): 
#                 dp_list.append(STAGE[t][part])
#         else: 
#             dp_list.append(STAGE[t])

#     running_start_dt = dt.now()
#     # overall_start_dt =  overall_start_dt.strftime("%m/%d/%Y %H:%M:%S")
#     now = dt.now().strftime("%m/%d/%Y %H:%M:%S")
#     print('Start time: {}'.format())
#     for dp in dp_list:
#         table_start_dt = dt.now()
#         sql_query, rows = pull_raw(dp)#, mtd_eng, omop_eng)
#         table_end_dt = dt.now()
#         log(dp, sql_query, rows)
#         print("The {} stage table has been successfully created with {} rows!".format(dp, rows))
#     running_end_dt = dt.now()
#     # overall_end_dt =  overall_start_dt.strftime("%m/%d/%Y %H:%M:%S")
#     print ('Finished at: {}'.format(running_end_dt))
#     duration = str(running_end_dt - running_start_dt)
#     print ('The duration is: {}\r\n'.format(duration))
    