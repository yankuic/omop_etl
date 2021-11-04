#coding=utf-8
"""Post-processing."""

import logging
import os

import sqlparse

from omop_etl.bo import format_stage_query
from omop_etl.utils import timeitd, timeitc
from omop_etl.io import read_sql
from omop_etl.datastore import DataStore
from omop_etl.config import ETLConfig


class Loader(DataStore, ETLConfig):
    """Main class for ETL methods.
    """
    def __init__(self, config_file):
        DataStore.__init__(self, config_file=config_file)
        ETLConfig.__init__(self)

    @timeitd
    def stage_hs_table(self, table):
        """Stage health system table.

        Args:
            table (str): care_site, provider, location
        """
        assert table in self.stage_hs.keys(), f'{table} is not a valid table name.'
        filepath = os.path.join(self.sql_scripts_path, self.stage_hs[table])
        q = read_sql(filepath) 

        return self.execute(q)

    @timeitd
    def stage_table(self, table, subset=None, sql_only=False):
        """Stage clinical data table

        Arguments:
            table (str): OMOP clinical data table: person, death, visit_occurrence, condition_occurrence, procedure_occurrence, drug_exposure, observation, measurement.
            subset (str, optional): Short name for table subset as appears in load section of the project config.yml file. Defaults to None.
            sql_only (bool, optional): If True, que query won't be executed and the method will return only the sql string. Defaults to False.
        """
        logging.info(f'Process to execute stage_table({table}, {subset}) is started.')
        assert table in self.stage.keys(), f'{table} is not a valid table name.'
        
        if subset: 
            assert subset in self.stage[table].keys(), f'{subset} is not a valid subset for {table}.'
            dp_name = self.stage[table][subset]
        else: 
            dp_name = self.stage[table]
            assert not isinstance(dp_name, (list, dict)), f'table {table} has subsets, but none was passed.' 

        col_aliases= self.aliases[dp_name]
        start_date = self.config.start_date
        end_date = self.config.end_date
        loincs = self.config.loinc

        with self.bo_engine.connect() as bo_con:
            con = self.engine.connect()
            execute_sp = format_stage_query(self.config.bo_docname_stage, dp_name, start_date, end_date, bo_con, con, 
                                            loinc_list=loincs, aliases=col_aliases)
            con.close()

        if sql_only:
            # Prettfy query string
            sql_parsed = sqlparse.parse(execute_sp)
            sql_string = sql_parsed[0]._groupable_tokens[2]\
                                      .tokens[1]\
                                      .normalized\
                                      .replace("''","#")\
                                      .replace("'","")\
                                      .replace("#","'")
            return sqlparse.format(sql_string, keyword_case='upper', reindent_aligned=True)

        else:      
            return self.execute(execute_sp)

    @timeitd
    def preload_table(self, table, subset=None):
        """Execute preload sql query.
        
        Arguments:
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
        """Load new records into mapping table.
        
        Arguments:
            table (str): Table name.
        """
        logging.info(f'Updating {table} ...')

        try:
            mapping_sql = self.mapping[table]
            q = read_sql(os.path.join(self.sql_scripts_path, mapping_sql))
        except KeyError as e:
            print(f'{table} is not registered as mapping table.')
            raise e

        return self.execute(q)
            
    @timeitd
    def load_table(self, table):
        """Execute load sql query.
        
        Arguments:
            table (str): Table name.
        """
        assert table in self.load.keys(), f'table name {table} is invalid.'
        logging.info(f'Process to execute load_table({table}) is started.')
    
        load_file = self.load[table]
        q = read_sql(os.path.join(self.sql_scripts_path, load_file))

        return self.execute(q)

    def preload_all_subsets(self, table):
        """Preload table with all subsets listed in the configuration file.
        
        Arguments:
            table (str): Table name.
        """
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

        Argument:
            dataset (str, optional): Options 'limited', 'deid'. Defaults to 'deid'.
        """
        script_file = self.postproc['hipaa']
        q = read_sql(os.path.join(self.sql_scripts_path, script_file))
        
        ## Load deid
        if dataset == 'deid':
            q = q.replace('@SetNULL','= NULL')\
                .replace('@DateShift','date_shift')\
                .format('birth_datetime_deid', 'race_concept_id_deid', 'ethnicity_concept_id_deid', 
                        'race_source_value_deid', 'ethnicity_source_value_deid', 'zipcode_deid', 'zipcode_deid') 

        ## Load limited
        elif dataset == 'limited':
            q = q.replace('@SetNULL','')\
                .replace('@DateShift','0')\
                .format('birth_datetime', 'race_concept_id', 'ethnicity_concept_id', 
                        'race_source_value', 'ethnicity_source_value', 'zipcode', 'zipcode')
        
        else:
            print(f'Option {dataset} not recognized')
            exit(1)

        return self.execute(q)

    @timeitd
    def fix_domains(self):
        """Move records to match domain table with concept domain_id. 
        """
        scripts = self.postproc['by_domain']
        for table in scripts.keys():
            q = read_sql(os.path.join(self.sql_scripts_path, scripts[table]))
            print(f'Moving records from {table} ...             ')
            self.execute(q)

    @timeitd
    def deid_condition(self):
        """De-identify condition_occurrence ICD codes.
        """
        script = self.postproc['deid_condition']
        q = read_sql(os.path.join(self.sql_scripts_path, script))
        print('De-identifying condition occurrence ...')
        
        return self.execute(q)
