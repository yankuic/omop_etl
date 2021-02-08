"""."""

from omop_etl.datastore import DataStore, read_sql
from omop_etl.postproc.load import Loader

store = DataStore('config.yml')

def create_new_project():
    raise NotImplementedError

