"""."""

from omop_etl.postproc.load import Loader

if __name__ == "__main__":
    l = Loader('omop')
    print(l.load_drug_exposure())
