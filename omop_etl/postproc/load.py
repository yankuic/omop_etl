#coding=utf-8
"""[summary].

Assumptions: 
    - Vocabulary tables are in xref schema.
    - Mapping tables are in xref schema.
    - Raw data are in stage schema.
    - Pre-processed data is in preload schema.
    - Postprocessed tables are in dbo schema.
"""

from omop_etl.utils import timeitd
from omop_etl.datastore import DataStore, execute, read_sql

# Register mapping, preload and load sql scripts here.
MAPPING = {
    'person': 'person_mapping.sql'
    #'visit_occurrence': 'visit_occurrence_mapping.sql'
}

PRELOAD = {
    'condition_occurrence': 'preload_condition.sql', 
    'procedure_occurrence': {
        'cpt': 'preload_procedure_cpt.sql', 
        'icd': 'preload_procedure_icd.sql'
    },
    'drug_exposure': {
        'order': 'preload_drug_order.sql', 
        'admin': 'preload_drug_admin.sql'
    }, 
    'measurement': {
        'bp': 'preload_measurement_bp.sql', 
        'heart_rate': 'preload_measurement_heart_rate.sql', 
        'height': 'preload_measurement_height.sql', 
        'lab': 'preload_measurement_lab.sql', 
        'lda': 'preload_measurement_lda.sql', 
        'pain': 'preload_measurement_pain.sql', 
        'qtcb': 'preload_measurement_qtcb.sql', 
        'res_dev': 'preload_measurement_res_dev.sql', 
        'res_etco2': 'preload_measurement_res_etco2.sql', 
        'res_fio2': 'preload_measurement_res_fio2.sql', 
        'res_gcs': 'preload_measurement_res_gcs.sql', 
        'res_o2': 'preload_measurement_res_o2.sql', 
        'res_peep': 'preload_measurement_res_peep.sql', 
        'res_pip': 'preload_measurement_res_pip.sql', 
        'res_resp': 'preload_measurement_res_resp.sql', 
        'res_spo2': 'preload_measurement_res_spo2.sql', 
        'res_tidal': 'preload_measurement_res_tidal.sql', 
        'res_vent': 'preload_measurement_res_vent.sql', 
        'rothman': 'preload_measurement_rothman.sql', 
        'sofa': 'preload_measurement_sofa.sql', 
        'temp': 'preload_measurement_temp.sql', 
        'weight': 'preload_measurement_weight.sql'
    }, 
    'observation': {
        'icu': 'preload_observation_icu.sql', 
        'payer': 'preload_observation_payer.sql', 
        'smoking': 'preload_observation_smoking.sql', 
        'zipcode': 'preload_observation_zipcode.sql'
    }
}

LOAD = {
    'person': 'load_person.sql',
    'death': 'load_death.sql',
    'condition_occurrence': 'load_condition.sql',
    'procedure_occurrence': 'load_procedure.sql',
    'drug_exposure': 'load_drug_exposure.sql',
    'measurement': 'load_measurement.sql'
}

class Loader:
    """Load data into OMOP confomant tables.

    Args:
        config_file (file): YAML file with project configuration parameters.

    """
    
    def __init__(self, config_file):
        self.store = DataStore(config_file) 
        self.engine = self.store.engine
        self.sql_path = 'omop_etl/postproc/sql/'

        try:
            self.load_param = self.store.config_param['load']
        except KeyError:
            print('Load parameters not found.')

    @timeitd
    def update_mappings(self, table):
        """Register new records in mapping table."""
        print(f'Updating {table} ...')
        try:
            mapping_sql = MAPPING[table]
            q = read_sql(self.sql_path + mapping_sql)
            return execute(q, self.engine)
        except KeyError:
            print(f'{table} is not registered as mapping table.')
        #TODO: function does not return output. 

    @timeitd
    def preload(self, table, subset=None):
        """Execute preload sql query."""
        print(f'Preloading {table} ({subset}) ...')
        if subset: 
            preload_file = PRELOAD[table][subset]
        else: 
            preload_file = PRELOAD[table]
        q = read_sql(self.sql_path + preload_file)
        return execute(q, self.engine)

    @timeitd
    def load_table(self, table, skip_preload=False):
        """Execute load sql query."""
        if skip_preload == False:
            if table in PRELOAD.keys():
                self.store.truncate('preload', table)
                if self.load_param[table]:
                    preload_list = list(self.load_param[table].keys())
                    for s in preload_list:
                        self.preload(table, s)
                else:
                    self.preload(table)
        
        print(f'Loading {table} ...')
        self.store.truncate('dbo', table)
        load_file = LOAD[table]
        q = read_sql(self.sql_path + load_file)
        return execute(q, self.engine)
