# %%
import os

import numpy as np
import pandas as pd

from omop_etl.utils import timeitc, timeitd

@timeitd
def to_csv(path, table, batch_size, schema, server, database):
    
    from turbodbc import connect, make_options, Megabytes

    options = make_options(read_buffer_size=Megabytes(batch_size), 
                           prefer_unicode=True,
                           use_async_io=True,
                           limit_varchar_results_to_max=True)

    con = connect(driver='{SQL Server}', server=server, database=database, 
                    trusted_connection='yes', turbodbc_options=options)

    cursor = con.cursor()
    cursor.execute(f"select * from {schema}.{table}")
    batches = cursor.fetchnumpybatches()

    count = 0
    csv_file = os.path.join(path, table + '.csv')

    with timeitc(f'Exporting {table}'):
        if os.path.exists(csv_file):
            os.remove(csv_file)

        for batch in batches:

            df = pd.DataFrame(batch)

            if count == 0:
                dtypes = {t:batch[t].dtype.type for t in batch.keys()}
                for dtype in dtypes.keys():
                    if dtypes[dtype] == np.int64:
                        dtypes[dtype] = 'Int64'
                    else:
                        dtypes[dtype] = 'str'

                df = df.astype(dtypes)
                df.to_csv(csv_file, index=False, sep='\t')

            else: 
                df = df.astype(dtypes)
                df.to_csv(csv_file, header=False, index=False, mode='a', sep='\t')

            count =+ 1

    con.close()

    return


def read_sql(filepath):
    """[summary].

    Args:
        filepath (str): Full path to sql file.

    """
    try:
        f = open(filepath, 'r')
        sql_string = f.read()
        f.close()
        return sql_string
    
    except Exception as e:
        # if e is IOError:
        #     print(f'Error: Failed to open {filepath}. File exists?')
        raise(e)