# -*- coding: utf-8 -*-
import os

import numpy as np
import pandas as pd

from omop_etl.utils import timeitc


def to_csv(path, table, batch_size, schema, server, database):
    """Export SQL table to CSV file.

    Args:
        path (str): Destination path for the CSV file.
        table (str): SQL table to save as CSV.
        batch_size (int): Batch size in megabytes. This is a turbodbc argument passed to the Megabytes class. 
        schema (str): Database schema.
        server (str): SQL server url.
        database (str): Database name.
    """
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

            df = pd.DataFrame(batch, dtype=str)

            if count == 0:
                dtypes = {t:batch[t].dtype.type for t in batch.keys()}
                # To avoid having ids exported as floats we need to convert to int.
                # However, a bug in pandas prevent to convert directly from object to int.
                # Instead, convert to float then to Int64
                dtypes_1 = {}
                dtypes_2 = {}
                for dtype in dtypes.keys():
                    if dtypes[dtype] == np.int64:
                        dtypes_1[dtype] = 'Int64'
                        dtypes_2[dtype] = 'float'
                    else:
                        dtypes_1[dtype] = 'str'
                        dtypes_2[dtype] = 'str'
                # for dtype in dtypes.keys():
                #     if dtypes[dtype] == np.int64:
                #         dtypes[dtype] = 'Int64'
                #     else:
                #         dtypes[dtype] = 'str'

                df = df.astype(dtypes_2).astype(dtypes_1)
                df.to_csv(csv_file, index=False, sep='\t')


            else: 
                df = df.astype(dtypes_2).astype(dtypes_1)
                df.to_csv(csv_file, header=False, index=False, mode='a', sep='\t')

            count =+ 1

    con.close()

    return


def import_csv(csv, table, batch_size, schema, server, database, truncate=True, **args):
    """Import CSV table into SQL server database.

    Args:
        csv (str): CSV file name. Note: NULLs will be imported as empty strings ''
        table (str): SQL table name. Must exists in the database.
        batch_size (int): Batch size in megabytes. This is a turbodbc argument passed to the Megabytes class. 
        schema (str): Database schema.
        server (str): SQL server url.
        database (str): Database name.
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

        # Try to read csv with explicit data types.
        # If import fails, read with str as data type.
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
    """Read sql script from file.

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
