"""."""

from omop_etl.postproc.load import Loader
import os

if __name__ == "__main__":
    l = Loader(config_file='config.yml')
    print(l.load_table('drug_exposure'))
    print(os.path.dirname(os.path.abspath(__file__)))
