"""."""

from omop_etl.postproc.load import Loader

if __name__ == "__main__":
    l = Loader(config_file='config.yml')
    print(l.load_drug_exposure())
