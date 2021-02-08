#coding:utf-8
"""[description]."""

from contextlib import contextmanager
import pandas as pd
import yaml
from sqlalchemy import create_engine


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

class DataStore:
    """Instantiate engine and configuration parameters.

    Arguments:
        store_name {str} -- Connection shortcut (omop, mtd).
        database {str} -- Database name (default: None). If database is None the datastore default database is passed to the connection string.
        config_file {str} --YAML file with project configuration parameters.
        *args {any} -- Additional arguments for sqlalchemy.create_engine.

    """

    def __init__(self, config_file, store_name=None, *args):
        with open(config_file) as f:
            self.config_param = yaml.safe_load(f)

        if store_name is None:
            store_name = 'omop'
        
        self.database = self.config_param['datastore'][store_name]['database']
        self.server = self.config_param['datastore'][store_name]['server']
        self._engine_str = f'mssql+pyodbc://{self.server}/{self.database}?driver=SQL+Server'
        self.engine = create_engine(self._engine_str, max_overflow=-1, *args)

    @contextmanager
    def connection(self):
        """Manage connection context."""
        con = self.engine.connect()
        tran = con.begin()

        try:
            yield con
        except:
            tran.rollback()
            raise
        else:
            tran.commit()
    
    def execute(self, query_string):
        """[summary]."""
        with self.connection() as con: 
            res = con.execute(query_string)
            return f'{res.rowcount} rows affected'

    def list_dbs(self):
        """List all databases in server."""
        q = '''
            SELECT [Database Name]= name, [Database ID] = database_id, Created = create_date
            FROM sys.databases;  
        '''

        with self.connection() as con:
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

        with self.connection()  as con:
            return pd.read_sql(q, con)

    def list_schemas(self, database=None):
        """List user schemas."""
        q = '''
        select s.name as schema_name, 
            s.schema_id,
            u.name as schema_owner
        from sys.schemas s
          inner join sys.sysusers u
          on u.uid = s.principal_id
        order by s.name
        '''

        if database is None:
            database = self.database

        with self.connection()  as con:
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

        with self.connection() as con:
            return pd.read_sql(query, con)
    
    def row_count(self, table, schema='dbo'):
        """Return row size of database table.
        
        Arguments:
            table {str} -- Table name.
            schema {str} -- Schema name.

        """
        with self.connection()  as con:
            query = "EXEC sp_spaceused '{}.{}'".format(schema, table)
            result = con.execute(query).next()

            return int(result[1].strip())

    def get_bo_query(self, doc_name): 
        """Retrieve query from BO.
        
        Arguments:
            doc_name {str} -- BO document name.
        """
        sql_metadata = """
        select DISTINCT DP_NAME, SQL_QUERY
        from DWS_METADATA.dbo.MD_MGMT_WEBI_DATA_PRVDRS
        where DOC_ID in (
            select DOC_ID
            from DWS_METADATA.dbo.MD_MGMT_WEBI_DOCS 
            where DOC_NAME = '{}'
        )
        """.format(doc_name)

        with self.connection()  as con:
            result = con.execute(sql_metadata).fetchall()
            return dict(result)

    def get_indexes(self, table, schema='dbo'):
        """[summary].

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

        with self.connection() as con:
            return pd.read_sql_query(q, con)

    def create_schema(self, schema):
        """Create new database schema.

        Args:
            schema (str): Schema name.

        """
        with self.connection()  as con: 
            q ='''
                IF NOT EXISTS (
                    SELECT * 
                    FROM sys.schemas
                    WHERE name = '{0}')
                    
                    EXEC('CREATE SCHEMA {0}')
            '''.format(schema)
            return self.execute(q)

    def object_exists(self, object_type, name):
        """Evaluate if object exist in database.

        Args:
            object_type (str): FN (scalar function), SQ (service queue), 
                        U (user table), PK (primary key constraint), S (system table), 
                        IT (internal table), P (stored procedure). 
            name (str): Object name. 
        """
        #TODO: implement option to set schema.

        q = '''
        select (case 
			when EXISTS (
				SELECT * 
				FROM sys.objects 
				WHERE type = '{}' AND OBJECT_ID = OBJECT_ID('{}')
			)
			then 1 
			else 0 
		end
        )'''.format(object_type, name)

        with self.connection()  as con:
            res = con.execute(q).fetchone()[0]
            
            if res == 1: 
                return True
            else:
                return False

    def truncate(self, schema, table):
        q = f'truncate table {schema}.{table}'
        return self.execute(q)
