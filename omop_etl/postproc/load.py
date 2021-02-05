#coding=utf-8
"""[summary].

Assumptions: 
    - Vocabulary tables are in xref schema.
    - Mapping tables are in xref schema.
    - Raw data are in stage schema.
    - Pre-processed data is in preload schema.
    - Postprocessed tables are in dbo schema.
"""

from omop_etl.utils import timeitd, timeitc
from omop_etl.datastore import DataStore, execute, read_sql

# Register mapping, preload and load sql scripts here.
MAPPING = {
    'person': 'person_mapping.sql',
    'visit_occurrence': 'visit_occurrence_mapping.sql'
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
        'heart_rate': 'preload_measurement_heartrate.sql', 
        'height': 'preload_measurement_height.sql', 
        'lab': 'preload_measurement_lab.sql', 
        'pain': 'preload_measurement_painscale.sql', 
        'qtcb': 'preload_measurement_qtcb.sql', 
        'res_dev': 'preload_measurement_res_device.sql', 
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
        'lda': 'preload_observation_lda.sql', 
        'vent': 'preload_observation_vent.sql',
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
    'measurement': 'load_measurement.sql',
    'observation': 'load_observation.sql',
    'visit_occurrence': 'load_visit_occurrence.sql',
    # populate these tables at the end and in order: provider, care_site, location
    'provider': 'load_provider.sql',
    'care_site': 'load_care_site.sql',
    'location': 'load_location.sql'
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
        """Load new records into mapping table."""
        print(f'Updating {table} ...')
        try:
            mapping_sql = MAPPING[table]
            q = read_sql(self.sql_path + mapping_sql)
            return execute(q, self.engine)
        except KeyError:
            print(f'{table} is not registered as mapping table.')

    @timeitd
    def preload(self, table, subset=None):
        """Execute preload sql query.
        
        Args:
            subset (str): Subset key (e.g. icd, cpt)or None. If None all subsets for table will be loaded. 
            Default: None. 

        """
        assert table in PRELOAD.keys(), f'{table} has no preload sql script.'
        print(f'Preloading {table} ({subset or "all"}) ...')
        
        if isinstance(PRELOAD[table], dict):
            if subset in PRELOAD[table].keys(): 
                preload_file = PRELOAD[table][subset]
                print(f'executing {preload_file} ...')
                q = read_sql(self.sql_path + preload_file)
                self.store.truncate('preload', table)
                return execute(q, self.engine)
            elif subset is None: 
                preload_list = list(self.load_param[table].keys())
                self.store.truncate('preload', table)
                for s in preload_list:
                    preload_file = PRELOAD[table][s]
                    print(f'executing {preload_file} ...')
                    q = read_sql(self.sql_path + preload_file)
                    print(execute(q, self.engine))
            else: 
                print(f'{subset} is not a valid option for argument subset or {table} has no subset key {subset}.')
        else:
            preload_file = PRELOAD[table]
            print(f'executing {preload_file} ...')
            q = read_sql(self.sql_path + preload_file)
            self.store.truncate('preload', table)
            return execute(q, self.engine)

    def preload_all(self):
        """Preload all active tables and subsets in the configuration file."""
        #read all tables/subsets from config 
        with timeitc('Preloading'):
            tables = self.load_param.keys()
            for t in tables:
                if t in PRELOAD.keys():
                    self.preload(t)

    @timeitd
    def load_table(self, table):
        """Execute load sql query."""
        print(f'Loading {table} ...')
        self.store.truncate('dbo', table)
        load_file = LOAD[table]
        q = read_sql(self.sql_path + load_file)
        return execute(q, self.engine)
