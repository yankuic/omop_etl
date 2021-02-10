"""The script that runs the ETL."""

from omop_etl.load import Loader

if __name__ == "__main__":
    l = Loader(config_file='config.yml')

    # print(l.update_mappings('person'))
    # print(l.update_mappings('visit_occurrence'))
    
    l.preload('condition_occurrence')
    # print(l.preload_all())
    
    # l.load_table('person')
    # l.load_table('death')
    # print(l.load_table('condition_occurrence'))
    # print(l.load_table('procedure_occurrence'))
    # print(l.load_table('drug_exposure'))
    # print(l.load_table('observation'))
    # print(l.load_table('provider'))
    # print(l.load_table('care_site'))
    # print(l.load_table('location'))

    # print(inspect.getfullargspec(l.load_table))
    
