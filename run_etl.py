"""The script that runs the ETL."""

import omop_etl as etl
from omop_etl.utils import timeitc

if __name__ == "__main__":
    #TODO: Create new object from which all other classes can inherit config.yml
    config_file='config.yml'
    stage = etl.Stager(config_file)
    load = etl.Loader(config_file)
    load_conf = stage.store.config_param['load']

    with timeitc('Processing'):

        for t in load_conf.keys():
            if load_conf[t]:
                for part in load_conf[t].keys():
                    print(stage.stage_table(t, part))
            else:
                if t not in ('provider','care_site','location'): 
                    print(stage.stage_table(t))
        # load.full_preload('person')
        # load.full_preload('death')
        # load.full_preload('visit')
        # load.full_preload('condition_occurrence')
        # load.full_preload('procedure_occurrence')
        # load.full_preload('drug_exposure')
        # load.full_preload('measurement')
        # load.full_preload('observation')

        # print(load.update_mappings('person'))
        # print(load.update_mappings('visit_occurrence'))

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

        # print(inspect.getfullargspec(load.load_table))
    
