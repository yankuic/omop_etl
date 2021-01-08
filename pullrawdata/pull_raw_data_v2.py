import sys
import os
import pandas as pd
import sqlalchemy
from omop_etl.datastore import DataStore
from datetime import datetime as dt

#   Utils   #

def index_containing_substring(the_list, substring):
    for i, s in enumerate(the_list):
        if substring in s:
              return i


#   Global variables   #
cur_path = os.path.dirname(__file__)
config_path = os.path.join(cur_path,'input_config.txt')
now = dt.now()
now_dt =  now.strftime("%m/%d/%Y %H:%M:%S")

with open(config_path,'r') as input_config:
    all_data = [line.strip() for line in input_config.readlines()]
    wh_host = str(all_data[index_containing_substring(all_data, 'wh_host')]).split('=')[1].strip()
    mtdt_db = str(all_data[index_containing_substring(all_data, 'mtdt_db')]).split('=')[1].strip()
    omop_db = str(all_data[index_containing_substring(all_data, 'omop_db')]).split('=')[1].strip()
    dp_names = all_data[index_containing_substring(all_data, 'dp_name')].split('=')[1]
    dp_list = dp_names.strip().split(', ') 
    start_date = str(all_data[index_containing_substring(all_data, 'start_date')]).split('=')[1].strip()
    end_date = str(all_data[index_containing_substring(all_data, 'end_date')]).split('=')[1].strip()
    patient_id_path = str(all_data[index_containing_substring(all_data, 'patient_file')]).split('=')[1].strip()
    _patient_id = pd.read_csv("{}".format(patient_id_path), dtype ={'id':'str'} )


#   Derived variables   #

mtd_db = 'mtd'
mtd_eng = DataStore(mtd_db).engine

omop_db = 'omop'
omop_eng = DataStore(omop_db).engine


patient_id = _patient_id['id'].astype(str).tolist()
patient_id = ','.join(patient_id)

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

        # Read out the SQL query and put in a dataframe
        omop_metadata = pd.read_sql(sql_metadata, self.mtd_eng)
        sql_query = omop_metadata.loc[omop_metadata.DP_NAME == self.dp_name, 'SQL_QUERY'].item()


        #############################
        #   Create Stored Procedure #
        #############################

        sql_query = sql_query.replace("12345678", patient_id)
        sql_query = sql_query.replace("01/01/1900 00:0:0", start_date)
        sql_query = sql_query.replace("12/31/1900 00:0:0", end_date)
        sql_query = sql_query.replace("'","''")

        create_sp = '''
        truncate table [DWS_OMOP].[stage].[{0}]
        insert into [DWS_OMOP].[stage].[{0}] with (tablock)
        {1} 
        '''.format(self.dp_name,sql_query)

        #################################
        #   Exexcute Stored Procedure   #
        #################################

        execute_sp = "execute ('use [DWS_PROD]; {}')".format(create_sp)

        con = self.omop_eng.connect()
        con.execute(execute_sp)
        tran_con = con.begin()
        tran_con.commit()


if __name__ == '__main__':
    stime = dt.now()
    print ('Start time: {}\r\n'.format(stime))
    for dp in dp_list:
        Puller(dp, mtd_eng, omop_eng).execute()
        datastore = DataStore('omop')
        row = datastore.row_count(dp, 'stage')
        print("The stage.{1} table has been successfully created. There are {0} row(s).".format(row, dp))
    print ('Finished at: {}'.format(dt.now()))
    print ('Total processing time (h:m:s): {}\r\n'.format(dt.now() - stime))
    