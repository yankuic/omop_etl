#coding=utf-8
"""[summary].

Assumptions: 
    - Vocabulary tables are in xref schema.
    - Mapping tables are in xref schema.
    - Raw data are in stage schema.
    - Pre-processed data is in preload schema.
    - Postprocessed tables are in dbo schema.
"""

import yaml
from omop_etl.utils import timeitc
from omop_etl.datastore import DataStore, execute, read_sql

class Loader:
    """[summary].

    Args:
        store_name (str): Connection shortcut.

    """
    
    def __init__(self, store_name, config_file):
        data_store = DataStore(store_name, config_file) 
        self.engine = data_store.engine
        self.sql_path = 'omop_etl/postproc/sql/'

        try:
            self.preload_param = data_store.config_param['preload']
        except KeyError:
            print('Preload parameters not found.')

    def preload(self, table):
        preload_list = list(self.preload_param[table].values())
        for s in preload_list:
            print(f'Executing {s} ...')
            with timeitc(f'Preloading'):
                q = read_sql(self.sql_path + s)
                execute(q, self.engine)
        return 0

    def load_person(self):
        q = read_sql(self.sql_path + 'load_person.sql')
        return execute(q, self.engine)

    def load_death(self):
        q = read_sql(self.sql_path + 'load_death.sql')
        return execute(q, self.engine)

    def load_drug_exposure(self):
        out = self.preload('drug')
        if out == 0:
            q = read_sql(self.sql_path + 'load_drug_exposure.sql')
            return execute(q, self.engine)
