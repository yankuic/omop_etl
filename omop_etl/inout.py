# %%
import os

import numpy as np
import pandas as pd

from omop_etl.utils import timeitc


def to_csv(path_or_buf, table, batch_size, schema, server, database):  #not reviewed
    
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
    # csvfile = os.path.join(path, table + '.csv')

    with timeitc(f'Exporting {table}'):
        if os.path.exists(path_or_buf):
            os.remove(path_or_buf)

        for batch in batches:

            df = pd.DataFrame(batch)

            dtypes = {t:batch[t].dtype.type for t in batch.keys()}
            for dtype in dtypes.keys():
                # print(f'turbodbc data type: {dtypes[dtype]}')
                if dtypes[dtype] == np.int64:
                    dtypes[dtype] = 'Int64'
                elif dtypes[dtype] == np.datetime64:
                    dtypes[dtype] = 'datetime64'
                elif dtypes[dtype] == np.float64:
                    dtypes[dtype] = 'float64'
                else:
                    dtypes[dtype] = 'object'
            
            df = df.astype(dtypes)
            # print(f'Converted data types\n: {df.dtypes}')
            
            if count == 0:
                df.to_csv(path_or_buf, index=False, sep='\t')
            else: 
                # df = df.astype(dtypes)
                df.to_csv(path_or_buf, header=False, index=False, mode='a', sep='\t')

            count =+ 1

    con.close()

    return


def import_csv(csv, table, batch_size, schema, server, database, replace_blanks=True, truncate=True, **args):
    """
    SQL table must exists
    NULLs will be imported as empty strings ''
    """
    from turbodbc import connect
    import numpy as np
    
    connection = connect(driver='{SQL Server}', server=server, 
                         database=database, trusted_connection='yes')
    cursor = connection.cursor()

    with timeitc(f'Importing data into table {table}'):
        #get table data types
        cursor = connection.cursor()
        cursor.execute(f'select top 1 * from {schema}.{table}')
        dtypes = {t[0]:t[1] for t in cursor.description}

        for t in dtypes.keys():
            if dtypes[t] == 10:
                dtypes[t] = np.int64
            elif dtypes[t] == 20:
                dtypes[t] = float
            else:
                dtypes[t] = str

        if truncate:
            truncate_str = f'truncate table {schema}.{table}'

            try:
                cursor.execute(truncate_str)
                connection.commit()
            except Exception as e:
                connection.rollback()
                connection.close()
                raise e

        #read csv
        try:
            next(pd.read_csv(csv, chunksize=1000, dtype=dtypes, **args))
            chunks = pd.read_csv(csv, chunksize=batch_size, dtype=dtypes, **args)

        except ValueError:
            chunks = pd.read_csv(csv, chunksize=batch_size, dtype=str, **args)

        count = 0
        rows = 0

        for chunk in chunks:

            if count == 0:
                columns = ','.join(chunk.columns)
                n_cols = len(chunk.columns)
                placehl = ','.join(['?']*n_cols)
                insert_query = f"""
                        set ansi_warnings off; 
                        insert into {schema}.{table} ({columns})
                        values ({placehl})
                        set ansi_warnings on
                """
                count=+1

            chunk = chunk.where(pd.notnull(chunk.replace('', np.nan)), None)

            try:
                cursor.executemanycolumns(insert_query, [np.ascontiguousarray(chunk[col].values) for col in chunk.columns])
                connection.commit()
                rows = rows + chunk.shape[0]

            except Exception as e:
                connection.rollback()
                connection.close()
                raise e

        connection.close()

        return f'{rows} rows affected'


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
