#coding:utf-8
"""[description]."""

from contextlib import contextmanager

#import pandas as pd
from sqlalchemy import create_engine

from omop_etl.config import ProjectConfig


class DataStore:
    """Initialize db connections. methods, and configuration parameters.

    Arguments:
        config_file {str} -- YAML file with project configuration parameters.
        *args {any} -- Additional arguments for sqlalchemy.create_engine.
    """
	
    
    def __init__(self, config_file, *args):
        self.config = ProjectConfig(config_file)
        self._proj_connection_str = self.config._proj_connection_str 
        self._bo_connection_str = self.config._bo_connection_str
    
    
    @property
    def engine(self, *args):
        return create_engine(self.connection_str, max_overflow=-1, *args)
    
    @property
    def bo_engine(self, *args):
        return create_engine(self._bo_connection_str, max_overflow=-1, *args)
    
    @property
    def connection_str(self):
        return self._proj_connection_str 
    
    @property
    def bo_connection_str(self):
        return self._bo_connection_str 
    
    @bo_connection_str.setter
    def bo_connection_str(self, connection_str):
        self._bo_connection_str = connection_str

    @connection_str.setter
    def connection_str(self, connection_str):
        self._proj_connection_str = connection_str

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

    def list_dbs(self): #not reviewed
        """List all databases in server."""
        q = """
            SELECT [Database Name]= name, 
                   [Database ID] = database_id, 
                   Created = create_date
            FROM sys.databases;  
        """

        with self.connection() as con:
            return pd.read_sql(q, con)

    def list_tables(self, database=None, in_schema=['dbo'], name_pattern=None): # not reviewed
        """List database tables."""
        schema_list = ','.join(["'{}'".format(schema) for schema in in_schema])

        if database is None:
            database = self.config.project_database
        
        q = """
            SELECT SCHEMA_NAME(schema_id) AS [Schema], name AS [Table]
            FROM sys.tables
            WHERE SCHEMA_NAME(schema_id) IN ({})
        """.format(schema_list)

        if name_pattern:
            q = """
                SELECT SCHEMA_NAME(schema_id) AS [Schema], name AS [Table]
                FROM sys.tables
                WHERE SCHEMA_NAME(schema_id) IN ({})
                AND name like '%{}%'
            """.format(schema_list, name_pattern)

        with self.connection()  as con:
            return pd.read_sql(q, con)

    def list_schemas(self, database=None): #not reviewed
        """List user schemas."""
        q = """
        select s.name as schema_name, 
            s.schema_id,
            u.name as schema_owner
        from sys.schemas s
          inner join sys.sysusers u
          on u.uid = s.principal_id
        order by s.name
        """

        if database is None:
            database = self.database

        with self.connection()  as con:
            return pd.read_sql(q, con)

    def find_column(self, pattern, in_schema=['dbo']): # not reviewed
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

    def row_count(self, table, schema='dbo'): #not reviewed
        """Return row size of database table.
        
        Arguments:
            table {str} -- Table name.
            schema {str} -- Schema name.

        """
        with self.connection()  as con:
            query = "EXEC sp_spaceused '{}.{}'".format(schema, table)
            result = con.execute(query).next()

            return int(result[1].strip())

    def get_indexes(self, table, schema='dbo'): #not reviewed
        """[summary].

        Arguments:
            table {[type]} -- [description]

        Keyword Arguments:
            schema {str} -- [description] (default: {'dbo'})

        Returns:
            [type] -- [description]

        """
        q = """
            EXEC sys.sp_helpindex @objname = N'{}.{}'
        """.format(schema, table)

        with self.connection() as con:
            return pd.read_sql_query(q, con)


    def create_schema(self, schema): # not reviewed
        """Create new database schema.

        Args:
            schema (str): Schema name.

        """
        with self.connection()  as con: 
            q ="""
                IF NOT EXISTS (
                    SELECT * 
                    FROM sys.schemas
                    WHERE name = '{0}')
                    
                    EXEC('CREATE SCHEMA {0}')
            """.format(schema)
            return self.execute(q)

    
    def object_exists(self, object_type, schema, name):
        """Evaluate if object exist in database.

        Args:
            object_type (str): FN (scalar function), SQ (service queue), 
                        U (user table), PK (primary key constraint), S (system table), 
                        IT (internal table), P (stored procedure). 
            name (str): Object name. 
        """

        q = f"""
        select (case 
			when EXISTS (
				SELECT * 
				FROM sys.objects 
				WHERE type = '{object_type}' 
                AND (name = '{name}' or  OBJECT_ID = OBJECT_ID('{name}'))
                AND SCHEMA_NAME(schema_id) = '{schema}'
			)
			then 1 
			else 0 
		end
        )"""

        with self.connection()  as con:
            res = con.execute(q).fetchone()[0]
            
            if res == 1: 
                return True
            else:
                return False
    
    def truncate(self, schema, table):
        q = f'truncate table {schema}.{table}'
        return self.execute(q)
    

    def archive_table(self, table):  #not reviewed
        q = """
        IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'archive')
        BEGIN
            EXEC( 'CREATE SCHEMA archive' );
        END
        
        DROP TABLE IF EXISTS archive.{0}
        SELECT *
        INTO archive.{0} 
        FROM dbo.{0}

        CREATE CLUSTERED COLUMNSTORE index cix_{0} on archive.{0}
        """.format(table)

        return self.execute(q)

	
