"""The script that runs the ETL."""

from os import read
import omop_etl as etl
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

        ## Pull patient cohort.

        # store.truncate('cohort','PersonList')
        # bo_q = store.get_bo_query('cohort_COVID_Broad')
        # cohort_q = format_insert_sql(bo_q.keys())

        # for t in bo_q.keys():
        #     q = bo_q[t]
        #     sqlstring = format_bo_sql(q, t)
        #     print(store.execute(f"EXECUTE ('USE DWS_PROD;\n {sqlstring}')"))

        # print(store.execute(cohort_q))

        ## Stage all tables

        # for t in load_conf.keys():
        #     if load_conf[t]:
        #         for part in load_conf[t].keys():
        #             print(stage.stage_table(t, part))
        #     else:
        #         if t not in ('provider','care_site','location'): 
        #             print(stage.stage_table(t))
        # print(stage.stage_table('person'))
        ## Update mapping tables before pre/loading

        # print(load.update_mappings('person'))
        # print(load.update_mappings('visit_occurrence'))

        ## Preload

        # load.full_preload('condition_occurrence')
        # load.full_preload('procedure_occurrence')
        # load.full_preload('drug_exposure')
        # load.full_preload('measurement')
        # load.full_preload('observation')

        ##Load 
        ## Load person and visit_occurrence before all others.
        # print(load.load_table('person'))
        # print(load.load_table('visit_occurrence'))
        # print(load.load_table('death'))
        # print(load.load_table('condition_occurrence'))
        # print(load.load_table('procedure_occurrence'))
        # print(load.load_table('drug_exposure'))
        # print(load.load_table('measurement'))
        # print(load.load_table('observation'))
        # print(load.load_table('provider'))
        # print(load.load_table('care_site'))
        # print(load.load_table('location'))

        q = read_sql('./omop_etl/sql/postprocessing.sql')
        print(store.execute(q))
