"""

"""
import os
import yaml

FILEDIR = os.path.dirname(os.path.abspath(__file__))
ETL_CONFIG = os.path.join(FILEDIR, 'etl_config.yml')
SQL_PATH = os.path.join(FILEDIR, 'sql')

class Config:
    def __init__(self, config_file):
        """Generic class to load config parameters.

        Args:
            config_file (str) -- YAML file with project configuration parameters.

        """
        try: 
            self._config = yaml.safe_load(open(config_file))
            #print(using config file at ... project name)
        except Exception as e:
            #FileNotFoundError
            #If file not found, print additional instructions. config file has to be in project directory.
            raise e

    def get_property(self, property_name):
        return self._config.get(property_name)


class ProjectConfig(Config):
    """Initialize project configuration parameters.
    """

    def _connection_str(self, server, database):
        return f'mssql+pyodbc://{server}/{database}?driver=SQL+Server'
    
    @property
    def _proj_connection_str(self):
        return self._connection_str(self.server, self.project_database)

    @property
    def _bo_connection_str(self):
        return self._connection_str(self.server, self._bo_database)

    @property
    def project_database(self):
        db_connections = self.get_property('db_connections')
        return db_connections['omop']['database']

    @property
    def bo_database(self):
        db_connections = self.get_property('db_connections')
        return db_connections['bo_metadata']['database']

    @property
    def server(self):
        db_connections = self.get_property('db_connections')
        return db_connections['omop']['server']

    @property
    def load(self):
        return self.get_property('load')

    @property
    def release_version(self):
        release_info = self.get_property('project_info')
        return release_info['version']

    @property
    def project_dir(self):
        project_info = self.get_property('project_info')
        return project_info['project_dir']

    @property
    def release_path(self):
        return os.path.join(self.project_dir, 'data_release', self.release_version)

    @property
    def start_date(self):
        date_range = self.get_property('date_range')
        return date_range['start_date']

    @property
    def end_date(self):
        date_range = self.get_property('date_range')
        return date_range['end_date']

    @property
    def bo_docname_stage(self):
        bo_docs = self.get_property('bo_docs') 
        return bo_docs['stage']

    @property
    def bo_docname_cohort(self):
        bo_docs = self.get_property('bo_docs') 
        return  bo_docs['cohort']


class ETLConfig(Config):
    """[summary]
    """
    def __init__(self, config_file=ETL_CONFIG):
        super(ETLConfig, self).__init__(config_file=config_file)
        self.sql_scripts_path = SQL_PATH

    @property
    def stage(self):
        return self.get_property('stage')
    
    @property
    def stage_hs(self):
        return self.get_property('stage_hs')

    @property
    def mapping(self):
        return self.get_property('mapping')

    @property
    def preload(self):
        return self.get_property('preload')

    @property
    def load(self):
        return self.get_property('load')
    
    @property
    def aliases(self):
        return self.get_property('aliases')
    
    @property
    def vocabularies(self):
        return self.get_property('omop_vocabs')

    @property
    def postproc(self):
        return self.get_property('postprocessing')

    @property
    def schema(self):
        return self.get_property('schema')
