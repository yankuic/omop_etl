#coding=utf-8
"""Post-processing."""

import logging
import os

from omop_etl.bo import format_stage_query
from omop_etl.utils import timeitd, timeitc
from omop_etl.inout import read_sql
from omop_etl.datastore import DataStore
from omop_etl.config import ETLConfig


class Loader(DataStore, ETLConfig):
    """Load data into OMOP tables.
    """
	    
    def __init__(self, config_file):
        DataStore.__init__(self, config_file=config_file)
        ETLConfig.__init__(self)
    
    @timeitd
    def stage_hs_table(self, table, only_query=False):
        #provider, care_site, and location tables
        assert table in self.stage_hs.keys(), f'{table} is not a valid table name.'
        filepath = os.path.join(self.sql_scripts_path, self.stage_hs[table]) #uses custom SQL scripts from 'sql' folder
        q = read_sql(filepath) 

        if only_query:
            return q
        else:
            return self.execute(q)
       
    @timeitd
    def stage_table(self, table, subset=None, only_query=False):
        """Stage clinical data table."""
        logging.info(f'Process to execute stage_table({table}, {subset}) is started.')
        assert table in self.stage.keys(), f'{table} is not a valid table name.'
        
        if subset: 
            assert subset in self.stage[table].keys(), f'{subset} is not a valid subset for {table}.'
            dp_name = self.stage[table][subset]
        else: 
            dp_name = self.stage[table]  #comes from etl_config.yml file
            assert not isinstance(dp_name, (list, dict)), f'table {table} contain subsets, but none was specified.' 

        col_aliases= self.aliases[dp_name]  #comes from etl_config.yml file
        start_date = self.config.start_date
        end_date = self.config.end_date
        loincs = self.config.loinc

        with self.bo_engine.connect() as bo_con:
            con = self.engine.connect()
            execute_sp = format_stage_query(self.config.bo_docname_stage, dp_name, start_date, end_date, bo_con, con, 
                                            loinc_list=loincs, aliases=col_aliases)
            con.close()

        if only_query:
            return execute_sp
        else:      
            return self.execute(execute_sp)
	
    
    @timeitd
    def preload_table(self, table, subset=None):
        """Execute preload sql query.
        
        Args:
            subset (str): Subset key (e.g. icd, cpt) or None. Default: None. 
        """
        assert self.preload.keys(), f'{table} is not a valid preload table.'
        
        logging.info(f'Process to execute preload {table} ({subset or "all"}) is started.')
        preload_f = self.preload.get(table)
        
        if isinstance(preload_f, dict):
            assert subset in self.preload[table].keys(), f'{table} has no subset {subset}.'
            sql_script_name = preload_f.get(subset)

        else: 
            sql_script_name = preload_f 
        
        logging.info(f'Executing {sql_script_name} ...')
        q = read_sql(os.path.join(self.sql_scripts_path, sql_script_name))
        
        return self.execute(q)
	
    @timeitd
    def update_mapping_table(self, table):
        """Load new records into mapping table."""
        logging.info(f'Updating {table} ...')

        try:
            mapping_sql = self.mapping[table]
            print(mapping_sql)			
            q = read_sql(os.path.join(self.sql_scripts_path, mapping_sql))
        except KeyError as e:
            print(f'{table} is not registered as mapping table.')
            raise e

        return self.execute(q)
	 
    @timeitd
    def load_table(self, table):
        """Execute load sql query."""
        assert table in self.load.keys(), f'table name {table} is invalid.'
        logging.info(f'Process to execute load_table({table}) is started.')
    
        load_file = self.load[table]
        q = read_sql(os.path.join(self.sql_scripts_path, load_file))

        return self.execute(q)
	
    def preload_all_subsets(self, table):
        """Preload table with all subsets listed in the configuration file."""
        #read all tables/subsets from config 
        with timeitc(f'Processing {table}'):
            self.truncate('preload', table)

            if isinstance(self.preload[table], dict):
                subsets = self.config.load[table].keys()
                print(f"Processing {table} subsets: {', '.join(subsets)}")
                for s in subsets:
                    print(self.preload_table(table, subset=s))

            else:
                print(f"Processing table: {table}")
                print(self.preload_table(table))
	
    @timeitd
    def load_hipaa(self, dataset='deid'):
        """Generate hipaa compliant dataset: de-identified, limited.

        Args:
            dataset (str, optional): Options 'limited', 'deid'. Defaults to 'deid'.
        """
        script_file = self.postproc['hipaa']
        q = read_sql(os.path.join(self.sql_scripts_path, script_file))
       
        ## Load deid
        if dataset == 'deid':
            q = q.replace('@SetNULL','= NULL')\
                .replace('@SetZero', '0')\
                .replace('@DateShift','date_shift')\
                .format('birth_datetime_deid', 'race_concept_id_deid', 'ethnicity_concept_id_deid', 'race_source_value_deid', 'ethnicity_source_value_deid', 'zipcode_deid', 'zipcode_deid') 

        ## Load limited
        elif dataset == 'limited':
            q = q.replace('@SetNULL','')\
                .replace('@SetZero', 'NULL')\
                .replace('@DateShift','0')\
                .format('birth_datetime', 'race_concept_id', 'ethnicity_concept_id', 'race_source_value', 'ethnicity_source_value', 'zipcode', 'zipcode')
        
        else:
            print(f'Option {dataset} not recognized')
            exit(1)

        return self.execute(q)

    @timeitd
    def fix_domains(self):
        scripts = self.postproc['by_domain']
        for table in scripts.keys():
            q = read_sql(os.path.join(self.sql_scripts_path, scripts[table]))
            print(f'Moving records from {table} ...             ')
            self.execute(q)

    @timeitd
    def deid_condition(self): #not reviewed
        script = self.postproc['deid_condition']
        q = read_sql(os.path.join(self.sql_scripts_path, script))
        print('De-identifying condition occurrence ...')
        
        return self.execute(q)
