#coding=utf-8
"""Methods for data post-processing."""

import logging
import yaml
from omop_etl.utils import timeitd, timeitc
from omop_etl.datastore import DataStore, read_sql

CONFIG = 'omop_etl/etl_config.yml'
with open(CONFIG) as f:
    yml = yaml.safe_load(f) 

MAPPING = yml['mapping']
PRELOAD = yml['preload']
LOAD = yml['load']


class Loader:
    """Load data into OMOP confomant tables.

    Args:
        config_file (file): YAML file with project configuration parameters.

    """
    
    def __init__(self, config_file):
        self.store = DataStore(config_file) 
        self.engine = self.store.engine
        self.sql_path = 'omop_etl/sql/'

        try:
            self.load_param = self.store.config_param['load']
        except KeyError:
            logging.error('Load parameters not found.')
            raise

    @timeitd
    def update_mappings(self, table):
        """Load new records into mapping table."""
        logging.info(f'Updating {table} ...')
        try:
            mapping_sql = MAPPING[table]
            q = read_sql(self.sql_path + mapping_sql)
            return self.store.execute(q)
        except KeyError:
            print(f'{table} is not registered as mapping table.')

    @timeitd
    def preload(self, table, subset=None):
        """Execute preload sql query.
        
        Args:
            subset (str): Subset key (e.g. icd, cpt) or None. Default: None. 
        """
        assert table in PRELOAD.keys(), f'{table} has no subset {subset}.'
        logging.info(f'Process to execute preload {table} ({subset or "all"}) is started.')
        
        if subset: 
            assert subset in PRELOAD[table].keys(), f'{table} has no subset key {subset}.'
            preload_file = PRELOAD[table][subset]
            logging.info(f'Executing {preload_file} ...')
            q = read_sql(self.sql_path + preload_file)

        else:
            assert not isinstance(PRELOAD[table], dict), f'{table} has no subsets'
            preload_file = PRELOAD[table]
            logging.info(f'Executing {preload_file} ...')
            q = read_sql(self.sql_path + preload_file)
                
        return self.store.execute(q)

    def full_preload(self, table):
        """Preload table with all subsets listed in the configuration file."""
        #read all tables/subsets from config 
        with timeitc(f'Processing {table}'):
            self.store.truncate('preload', table)
            if isinstance(PRELOAD[table], dict):
                subsets = self.load_param[table]
                print(f"Processing {table} subsets: {', '.join(subsets)}")
                for s in subsets:
                    print(self.preload(table, subset=s))
            else:
                print(f"Processing table: {table}")
                print(self.preload(table))

    @timeitd
    def load_table(self, table):
        """Execute load sql query."""
        logging.info(f'Process to execute load_table({table}) is started.')
    
        load_file = LOAD[table]
        q = read_sql(self.sql_path + load_file)

        return self.store.execute(q)
