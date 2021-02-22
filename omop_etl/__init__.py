"""."""
import logging

from omop_etl.datastore import DataStore, read_sql
from omop_etl.load import Loader

logging.basicConfig(filename='omop_etl.log', 
                    format='%(asctime)s: %(message)s', 
                    level=logging.INFO,
                    datefmt='%m/%d/%Y %I:%M:%S %p')

store = DataStore('config.yml')

def create_new_project(project_path):
    raise NotImplementedError

