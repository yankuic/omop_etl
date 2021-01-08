#coding:utf-8
"""[description]."""

import os
import pandas as pd
from sqlalchemy import create_engine

STORE = {
    'omop': ['edw.shands.ufl.edu', 'DWS_OMOP'], 
    'mtd': ['edw.shands.ufl.edu', 'DWS_METADATA']
}

def execute(query_string, engine):
    """[summary].

    Args:
        query_string ([type]): [description]
        engine ([type]): [description]

    """
    with engine.connect() as connection: 
        tran = connection.begin()
        try:
            res = connection.execute(query_string)
            tran.commit()
            return f'{res.rowcount} rows affected'

        except Exception as e:
            tran.rollback()
            raise(e)

def read_sql(filepath):
    """[summary].

    Args:
        filepath (str): Full path of sql file.

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

class DataStore:
    """Instantiate db engine.

    Arguments:
        store_name {str} -- Connection shortcut (omop, mtd).
        database {str} -- Database name (default: None). If database is None the datastore default database is passed to the connection string.
        *args {any} -- Additional arguments for sqlalchemy.create_engine.

    """

    def __init__(self, store_name, database=None, *args):
        server_str, default_db = STORE[store_name]

        if database is None:
            database = default_db
        
        self.server = server_str
        self.database = database
        self._engine_str = f'mssql+pyodbc://{server_str}/{database}?driver=SQL+Server'
        self.engine = create_engine(self._engine_str, max_overflow=-1, *args)
    
    def list_dbs(self):
        """List all databases in server."""
        q = '''
            SELECT [Database Name]= name, [Database ID] = database_id, Created = create_date
            FROM sys.databases;  
        '''

        with self.engine.connect() as con:
            return pd.read_sql(q, con)

    def list_tables(self, database=None, in_schema=['dbo'], name_pattern=None):
        """List database tables."""
        schema_list = ','.join(["'{}'".format(schema) for schema in in_schema])

        if database is None:
            database = self.database
        
        q = '''
            SELECT SCHEMA_NAME(schema_id) AS [Schema], name AS [Table]
            FROM sys.tables
            WHERE SCHEMA_NAME(schema_id) IN ({})
        '''.format(schema_list)

        if name_pattern:
            q = '''
                SELECT SCHEMA_NAME(schema_id) AS [Schema], name AS [Table]
                FROM sys.tables
                WHERE SCHEMA_NAME(schema_id) IN ({})
                AND name like '%{}%'
            '''.format(schema_list, name_pattern)

        with self.engine.connect() as con:
            return pd.read_sql(q, con)

    def find_column(self, pattern, in_schema=['dbo']):
        """Search column name matching pattern across all tables in the database.
        
        Arguments:
            pattern {str} -- String patter to match.
            in_schema {list} -- List of schemas to search in. 

        """        
        schema_list = ','.join(["'{}'".format(schema) for schema in in_schema])

        query = """
            SELECT SCHEMA_NAME(schema_id) AS schema_name,
                   t.name AS table_name,
                   c.name AS column_name
              FROM sys.tables AS t
             INNER JOIN sys.columns c ON t.OBJECT_ID = c.OBJECT_ID
             WHERE c.name like '%{}%' 
               AND SCHEMA_NAME(schema_id) IN ({})
             ORDER BY schema_name, table_name;
        """.format(pattern, schema_list)

        with self.engine.connect() as con:
            return pd.read_sql(query, con)
    
    def row_count(self, table, schema='dbo'):
        """Return row size of database table.
        
        Arguments:
            table {str} -- Table name.
            schema {str} -- Schema name.

        """
        with self.engine.connect() as con:
            query = "EXEC sp_spaceused '{}.{}'".format(schema, table)
            result = con.execute(query).next()

            return int(result[1].strip())

    def get_indexes(self, table, schema='dbo'):
        """[summary]

        Arguments:
            table {[type]} -- [description]

        Keyword Arguments:
            schema {str} -- [description] (default: {'dbo'})

        Returns:
            [type] -- [description]

        """
        q = '''
            EXEC sys.sp_helpindex @objname = N'{}.{}'
        '''.format(schema, table)

        with self.engine.connect() as con:
            return pd.read_sql_query(q, con)
