import configparser
import os

import pandas as pd
import numpy as np

from omop_etl.load import Loader
from omop_etl.inout import to_csv
from omop_etl.utils import timeitc

print(f'Current directory is {os.getcwd()}')
config = configparser.ConfigParser()
config.read('./test/test.ini')

CONFIG_FILE = os.path.join(config['test_env']['config_path'], 'config.yml')
loader = Loader(CONFIG_FILE)

SERVER = loader.config.server
RELEASE_VERSION = f'v{loader.config.release_version}'
RELEASE_PATH = loader.config.release_path
DATABASE = loader.config.project_database
BATCH_SIZE = 500


# create dummy table with data types.
q = """
    drop table if exists test.export_dtypes;

    create table test.export_dtypes (
        int_val int null,
        float_val float null,
        str_val varchar(10) null,
        dt_val datetime null,
        date_val date null
    )

    insert into test.export_dtypes 
    values (1,1.2345,'string', '2022-05-31 14:50:32.597', '2022-05-31'),
           (2,NULL,NULL,NULL, NULL),
           (NULL,0.567,'','1900-01-01', '1900-01-01 00:00:00.00')
"""

with loader.engine.connect() as con:
    con.execute(q)

dirpath = os.path.join(RELEASE_PATH, 'unittest_results')
        
if not os.path.exists(dirpath):
    os.makedirs(dirpath)

out_path = os.path.join(RELEASE_PATH, 'unittest_results', f'export_dtypes_{RELEASE_VERSION}.0.txt')

with timeitc('Export to table'):
    to_csv(out_path, 'export_dtypes', BATCH_SIZE, 'test', SERVER, DATABASE)

df = pd.read_csv(out_path, sep='\t', dtype=str)

exp_df = pd.DataFrame(
    {
        'int_val': [1,2,np.nan],
        'float_val': [1.2345,np.nan,0.567],
        'str_val': ['string',np.nan,pd.np.nan],
        'dt_val': ['2022-05-31 14:50:32.597',np.nan,'1900-01-01 00:00:00.000'],
        'date_val': ['2022-05-31',np.nan,'1900-01-01']
    },
    dtype=str
)

os.remove(out_path)

assert exp_df.equals(df), 'Unexpected values while validating data types export.'

print('Data types export test succeeded.')
