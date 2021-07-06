import pandas as pd
from omop_etl.load import Loader

loader = Loader('config.yml')
STAGE = loader.stage
LOAD = loader.config.load

def report_counts():
    result = []
    for t in LOAD.keys():
        if t not in ['provider','care_site','location']:
            if LOAD[t]:
                for part in LOAD[t]:
                    stg_name = STAGE[t][part]
                    count = loader.row_count(stg_name, schema='stage')
                    result.append([t, part, count])
            else:
                stg_name = STAGE[t]
                count = loader.row_count(stg_name, schema='stage')
                result.append([t, None, count])

    table_counts = pd.DataFrame(result, columns=['Table', 'Part', 'Stage_RC'])


    # %%
    count_diff = table_counts.groupby('Table').sum().reset_index()
    count_diff['Load_RC'] = count_diff.Table.apply(lambda t: loader.row_count(t))
    count_diff['DeId_RC'] = count_diff.Table.apply(lambda t: loader.row_count(t, schema='hipaa'))
    count_diff['Preload_RC'] = count_diff.Table.apply(lambda t: loader.row_count(t, schema='preload') if t not in ('death','person','visit_occurrence') else 0)
    
    return print(count_diff)
