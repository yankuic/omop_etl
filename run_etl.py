"""The script that runs the ETL."""

from logging import setLogRecordFactory
from os import read
import omop_etl as etl
from omop_etl import datastore
from omop_etl.utils import timeitc
from omop_etl.cohort import format_insert_sql
from omop_etl.datastore import format_bo_sql, read_sql

if __name__ == "__main__":
    #TODO: Create new object from which all other classes can inherit config.yml
    config_file='config.yml'
    store = etl.DataStore(config_file)
    stage = etl.Stager(config_file)
    load = etl.Loader(config_file)
    load_conf = stage.store.config_param['load']

    with timeitc('Processing'):

        ## Get patient cohort.

        # store.truncate('cohort', 'PersonList')
        # bo_q = store.get_bo_query('cohort_COVID_Broad')
        # cohort_q = format_insert_sql(bo_q.keys())
        # end_date = store.config_param['date_range']['end_date']

        # for t in bo_q.keys():
        #     q = bo_q[t]
        #     sqlstring = format_bo_sql(q, t)
        #     print(f'Loading {t} ...')
        #     print(store.execute(f"EXECUTE ('USE DWS_PROD;\n {sqlstring}')"))
        # print('Loading cohort table ...')
        # print(store.execute(cohort_q))

        ## Stage tables

        # for t in load_conf.keys():
        #     if load_conf[t]:
        #         for part in load_conf[t].keys():
        #             print(stage.stage_table(t, part))
        #     else:
        #         if t not in ('provider','care_site','location'): 
        #             print(stage.stage_table(t))

        ## print(stage.stage_table('visit_occurrence'))
        ## print(stage.stage_table('measurement', 'res_vent_peds'))

        ## Stage health system tables

        # q = read_sql('./omop_etl/sql/stage_provider.sql')
        # print(store.execute(q))

        # q = read_sql('./omop_etl/sql/provider_mapping.sql')
        # print(store.execute(q))

        # q = read_sql('./omop_etl/sql/stage_care_site.sql')
        # print(store.execute(q))

        # q = read_sql('./omop_etl/sql/care_site_mapping.sql')
        # print(store.execute(q))

        # q = read_sql('./omop_etl/sql/stage_location.sql')
        # print(store.execute(q))

        # q = read_sql('./omop_etl/sql/location_mapping.sql')
        # print(store.execute(q))

        ## Update mapping tables before pre/loading

        # print(load.update_mappings('person'))
        # print(load.update_mappings('visit_occurrence'))

        ## Preload
        ## print(load.preload('measurement', 'res_gcs_peds'))
        # load.full_preload('condition_occurrence')
        # load.full_preload('procedure_occurrence')
        # load.full_preload('drug_exposure')
        # load.full_preload('measurement')
        # load.full_preload('observation')

        ## Load 
        ## Load person and visit_occurrence before all others.
        # store.truncate('dbo', 'person')
        # print(load.load_table('person'))
        # store.truncate('dbo', 'visit_occurrence')
        # print(load.load_table('visit_occurrence'))
        # store.truncate('dbo', 'provider')
        # print(load.load_table('provider'))
        # store.truncate('dbo', 'care_site')
        # print(load.load_table('care_site'))
        # store.truncate('dbo', 'location')
        # print(load.load_table('location'))
        # store.truncate('dbo', 'observation_period')
        # print(load.load_table('observation_period'))
        # store.truncate('dbo', 'death')
        # print(load.load_table('death'))
        # store.truncate('dbo', 'condition_occurrence')
        # print(load.load_table('condition_occurrence'))
        # store.truncate('dbo', 'procedure_occurrence')
        # print(load.load_table('procedure_occurrence'))
        # store.truncate('dbo', 'drug_exposure')
        # print(load.load_table('drug_exposure'))
        # store.truncate('dbo', 'measurement')
        # print(load.load_table('measurement'))
        # store.truncate('dbo', 'observation')
        # print(load.load_table('observation'))

        ## Move records by domain
        # q = read_sql('./omop_etl/sql/postprocess_by_domain.sql')
        # print(store.execute(q))

        ## Load deid
        q = read_sql('./omop_etl/sql/postprocess_hipaa.sql')
        q = q.replace('@SetNULL','= NULL')\
             .replace('@DateShift','date_shift')\
             .format('birth_datetime_deid','zipcode_deid') 
        print(store.execute(q))

        ## Load limited
        # q = read_sql('./omop_etl/sql/postprocess_hipaa')
        # q = q.replace('@SetNULL','')\
        #      .replace('@DateShift','0')\
        #      .format('birth_datetime','zipcode')
        # print(store.execute(q))
