# OMOP ETL

## Preliminaries

> Windows uses back slashes in URLs. Therefore, we need to change all back slashes to forward slashes since Git Bash is Linux based.

## Part I. Installation

### Setting up conda environment and installing required libraries

1. Make sure you have Anaconda installed on your system. If not, go to [anaconda.com](https://www.anaconda.com/products/individual) and follow instructions to download and install.

2. Open the command line and create new python environment

    Create a new environment named omop_etl (or any othe name you like).

    ```bash
    conda create -n omop_etl python=3.7
    ```

    Activate your new environment

    ```bash
    conda activate omop_etl
    ```

3. Install required python libraries

    Install turbodbc from wheel

    ```bash
    pip install -r //share.ahc.ufl.edu/share$/DSS/IDR_Projects/OMOP/python_env/requirements.txt
    ```

    Pip may complain due to missing dependencies with Numpy, ignore it for now:

    ```text
    ERROR: pip's dependency resolver does not currently take into account all the packages that are installed. This behaviour is the source of the following dependency conflicts.
    pyarrow 0.13.0 requires numpy>=1.14, which is not installed.
    ```

    Install other dependencies from Anaconda repo

    ```bash
    conda install numpy pandas pyodbc selenium sqlalchemy sqlparse pyyaml
    ```

4. Install optional packages

    ```bash
    conda install jupyter jupyterlab
    ```

### Install omop_etl package

Make sure you have Git installed on your system. If not, go to [git-scm.com](https://git-scm.com/download/win) and follow instructions to download and install.

1. Launch git bash on the location where the cloned directory will be stored.

2. If this is your first time pulling the central Git repository (repo) from IDR shared drive, you need to clone the repo to your local directory first. Otherwise, skip this step.

    ```bash
    git clone //share.ahc.ufl.edu/Share$/DSS/IDR_Projects/GitRepo/OMOP/omop_etl.git
    ```

3. Install omop_etl package

    Change your working directory to the cloned omop_etl folder.

    ```bash
    cd omop_etl/
    ```

    Install package

    ```bash
    python setup.py install --record files.txt
    ```

    Note: Option --record saves the path of all files installed into files.txt. This will make your life easier if you want to uninstall the package later on.

    To uninstall run

    ```bash
    # this is not working on my system.
    xargs rm -rf < files.txt
    ```

## Part II. Setting up new OMOP project

1. Create new project

    The first step is to create a folder to store the configuration files and vocabulary tables necessary to setup an OMOP project.

    ```bash
    omop_etl new_project --path <path to new project> --name <myproject> --server <SQL server url> --database <project database>
    ```

    Example:

    ```bash
    omop_etl new_project -p ./ -n omop_project1 -db dws_cc_omop -s edw.shands.ufl.edu
    ```

    After running the command, a new project directory will be created with the following content:

    ```bash
    omop_project_dir
    |__config.yml
    |__refresh_cohort.py
    |__vocabulary
        |__source_to_concept_map.csv
    ```

    *config.yml* is the project configuration file that stores all project configuration parameters: project info, project date range, list of tables to load, sql connection information, vocabulary list, BO document names, and LOINC codes list. Most parameters are preset. The following elements must be provided:
        - project_info/hipaa: options 'deid','limited'. If none the a fully identified registry will be created.
        - date_range/start_date: start date for patient records
        - date_range/end_date: end date for patient records
        - bo_docs/cohort: name of the BO document
        - db_connections/omop/server (if the parameter -s was not provided): sql server host
        - db_connections/omop/database (if the parameter -db was not provided): project database

    If options --server and --database were used as indicated above, the connection parameters should be set already in config.yml. Presets can be modifided depending on the needs of each project. For example, the analyst can comment subset load/measurement/res_tidal if she doen't want to load that element into a patient registry. In the same maner, LOINC codes can be excluded or added using this file.

    *refresh_cohort.py* is a script template to load the cohort patient list based in the COVID OMOP registry. The analyst will need to customize this script to meet the inclusion/exclusion criteria for the project cohort.

    Athena vocabularies are stored in the *vocabulary* folder. Only the template for *source_to_concept_map.csv* is automatically created. This table contain custom mappings from source codes (e.g. ICD9) to OMOP standard vocabularies. At the moment, all other vocabulary tables must be manually downloaded from [Athena](https://athena.ohdsi.org) website and extracted into this directory (see step 3).

2. Create project schema on a blank database.

    ```bash
    omop_etl create_schema
    ```

    This command will create the following schemas:

    - **xref** for vocabulary and mapping tables.
    - **stage** for raw data.
    - **preload** for pre-processed data.
    - **dbo** for final tables in OMOP format. Data in dbo contain PHI.
    - **hipaa** for data conforming with hipaa deidentified or limited datasets.
    - **archive** for backing up dbo tables.

3. Load vocabulary tables into project database.

    - Download vocabulary tables from [Athena](https://athena.ohdsi.org).
        - Register to Athena
        - Login with your Athena credentials
        - Click on the DOWNLOAD tab
        - Select the vocabularies from the vocabulary list
        - Click button download ovocabularies
    - Unzip and save vocabulary tables into the project vocabulary directory.
    - Load tables from the project vocabulary directory into the project database.

        ```bash
        omop_etl vocab --all
        ```

## Part III. Using OMOP_ETL comand line interface

All commands must be executed within the omop project directory, where files config.yml and refresh_cohort.py must exist.

1. Load cohort patient list into PersonList table in db.

    ```bash
    python refresh_cohort.py
    ```

2. Staging data. Run BO queries to extract data from the warehouse.

    ```bash
    omop_etl stage --all
    ```

    Note: Mapping tables will be updated during this step.

3. Preload. This will consolidate data from tables in the stage schema into a single table. Mappings to OMOP concepts also takes place during this step.

    ```bash
    omop_etl preload --all
    ```

    Note: If the registry is de-identified, de-identification of diagnosis codes with take place during this step.

4. Load. Data from preload schema are loaded into OMOP conforming tables.

    ```bash
    omop_etl load --all
    ```

    Note: Derived tables observation_period, drug_era, and condition_era are populated during this step.

5. Fix domains. During this step, records from condition_occurrence, procedure_occurrence, drug_exposure, observation, and measurement will be reallocated to match the domain_id of the standard concept. 

    ```bash
    omop_etl postproc --fix_domains
    ```

    Note: The table device_exposure is populated during this step with records from procedure_occurrence.

6. Generate hipaa compliant registry.

    For de-identified dataset run

    ```bash
    omop_etl postproc --deid
    ```

    For limited dataset run

    ```bash
    omop_etl postproc --limited
    ```

7. Export to csv files. Not implemented
