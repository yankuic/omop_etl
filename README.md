# OMOP ETL

## Part I. Installation

### Setting up python environment and installing required libraries

#### Using Anaconda

1. Make sure you have Anaconda installed on your system. If not, go to [anaconda.com](https://www.anaconda.com/products/individual) and follow instructions to download and install. Make sure to choose the 64b version.

2. Create new conda environment.

    Create a new environment named omop_etl (or any othe name you like). Open the command line and follow the steps below.

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

    Pip may complain due to missing dependencies with Numpy. If you get the following error, ignore it for now:

    ```text
    ERROR: pip's dependency resolver does not currently take into account all the packages that are installed. This behaviour is the source of the following dependency conflicts.
    pyarrow 0.13.0 requires numpy>=1.14, which is not installed.
    ```

    Install other dependencies from Anaconda repository.

    ```bash
    conda install numpy pandas pyodbc selenium sqlalchemy sqlparse pyyaml
    ```

4. Install optional packages

    ```bash
    conda install jupyter jupyterlab
    ```

#### Using stand alone python environment

1. Downlaoad and install [python 3.7 (64b) for Windows](https://www.python.org/ftp/python/3.7.0/python-3.7.0-amd64.exe). Installing in c:/ or in your data drive (e:/) is recommended.
2. Install required python libraries

    Install turbodbc from wheel

    ```bash
    pip install -r //share.ahc.ufl.edu/share$/DSS/IDR_Projects/OMOP/python_env/requirements.txt
    ```

   Pip may complain due to missing dependencies with Numpy. If you get the following error, ignore it for now:

    ```text
    ERROR: pip's dependency resolver does not currently take into account all the packages that are installed. This behaviour is the source of the following dependency conflicts.
    pyarrow 0.13.0 requires numpy>=1.14, which is not installed.
    ```

    Install other dependencies.

    ```bash
    pip install numpy pandas pyodbc selenium sqlalchemy sqlparse pyyaml
    ```

3. Optional packages (not required to run omop_etl, only install if you use them for development)

    ```bash
    pip install jupyter jupyterlab
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
    python setup.py install
    ```

    To uninstall delete omop_etl installation directory

    ```bash
    rm -R <path to installation directory, e.g. c:\Python37\Lib\site-packages\omop_etl-0.1-py3.7.egg>
    ```

## Part II. Setting up new OMOP project

1. Create new project

    The first step is to create a folder to store the configuration files and vocabulary tables necessary to setup an OMOP project.

    ```bash
    omop_etl new_project --path <path to new project> --name <myproject> --server <SQL server url> --database <project database>
    ```

    Example:

    ```bash
    omop_etl new_project --path //shandsdfs.shands.ufl.edu/FILES/SHARE/DSS/IDR_Projects/OMOP/TestProject --name omop_project_name --server dwsrsrch01.shands.ufl.edu --database dws_omop
    ```

    After running the command, a new project directory will be created with the following content:

    ```bash
    omop_project_dir
    |__config.yml
    |__refresh_cohort.py
    |__vocabulary
        |__source_to_concept_map.csv
    ```

    *config.yml* is the project configuration file that stores all project-specific configuration parameters: project info, project date range, BO document names, list of tables to load, sql db connection information, vocabulary list, and LOINC codes list.

    Most parameters are preset, but can be modifided depending on the needs of each project. To exclude data elements or LOINC codes add the character # at the begining of the line. In the example below  the subset load/measurement/res_tidal is commented and won't be loaded into the measurement table.

    ```yml  
    load:
        measurement:
    #       res_tidal:
    ```

    The following parameters are mandatory:

    - project_info
      - project_dir is automatically generated by the ```omop_etl new_project``` script and should not be changed.
      - version: ```@Yankuic``` What is version? Should this be manually entered? How is it used? *my original plan was to store the package version automatically*
      - hipaa: options 'deid','limited'. If left blank, a fully identified registry will be created.
      - date_range*
        - start_date: start date for patient records.
        - end_date: end date for patient records.
      - bo_docs
        - cohort: name of the BO .wid document that is saved in OMOP folder on the [BI server](https://bi.shands.ufl.edu/BOE/BI/) to identify the cohort for the project.
        - stage: name of the BO .wid document that is saved in OMOP folder on the [BI server](https://bi.shands.ufl.edu/BOE/BI/) to pull data. This name should not be changed by an analyst running the pipeline.
      - db_connections**
        - server: sql server host
        - database: project database

    \*Note that the date range will apply to all queries within the stage BO .wid document. This range does not apply to the cohort inclusion criteria. The date range for queries in the cohort BO .wid document has to be defined in the *refresh_cohort.py* script.

    \*\*If options --server and --database were passed to the `omop_etl new_project` command, as indicated above, the connection parameters should be set already in config.yml.

    *refresh_cohort.py* is a script template to load the cohort patient list based in the COVID OMOP registry. The analyst will need to customize this script to meet the inclusion/exclusion criteria for the project cohort. The script can be modified to use a different date range or a different algorithm to select the patient cohort. The default python script assumes that the start date will be included in the BO query, and the end date is either included in the BO query or there is a placeholder in BO query '12/31/1900 00:0:0', which will be replaced with the end_date of date_range for data pull, thus assuming that end date of identifying the cohort and end data of data elements is the same. The default behavior of the script is that it takes the union of all bo queries specifying inclusion criteria. If a more complex logic needs to be implemented, we need to modify load_cohort_query() method in refresh_cohort.py script.

    Athena vocabularies are stored in the *vocabulary* folder. Only the template for *source_to_concept_map.csv* is automatically created. This table contain custom mappings from source codes (e.g. ICD9) to OMOP standard vocabularies. At the moment, all other vocabulary tables must be manually downloaded from [Athena](https://athena.ohdsi.org) website and extracted into this directory (see step 3).

2. Create project schema on a blank database.Requires a pre-existing empty database.

    Run the following command within the project directory.

    `@Tanja` will come back to review this part of documentation and code.

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

     `@Tanja`: code and documentation not fully reviewed yet.

    - Download vocabulary tables from [Athena](https://athena.ohdsi.org).
        - Register to Athena
        - Login with your Athena credentials
        - Click on the DOWNLOAD tab
        - Select the vocabularies from the vocabulary list `@Yankuic` How does one know what vocabularies to download?
        - Click button to download vocabularies
    - Unzip and save vocabulary tables into the project vocabulary directory. `@Yankuic` Isn't there a step to load CPT codes?
    - Load tables from the project vocabulary directory into the project database.

        ```bash
        omop_etl vocab --all
        ```

## Part III. Using OMOP_ETL comand line interface

All commands must be executed within the omop project directory, where files config.yml and refresh_cohort.py must exist.

1. Load cohort patient list into PersonList table in db.

    `@Tanja` to come back here to review code and documentation of code itself.

    ```bash
    python refresh_cohort.py
    ```

2. Staging data. During this step SQL code generated by BO queries is executed to extract data from the warehouse and loaded into stage tables. Data elements commented out in config.yml file will be ignored. In addition, the following mapping tables will be updated during this step: person_mapping, visit_occurrence_mapping, provider_mapping, care_site_mapping, location_mapping.

    ```bash
    omop_etl stage --all
    ```

    Alternatively, tables can be staged individually.

    ```bash
    # stage person table
    omop_etl stage --table person
    ```

    To stage tables with subsets (condition_occurrence, procedure_occurrence, drug_exposure, measurement, observation) we need to pass an additional option

    ```bash
    # stage subset res_device from measurement table
    omop_etl stage --table measurement --subset res_device

    # stage all subsets from measurement table
    omop_etl stage --table measurement --subset all
    ```

3. Preload. During this step, subset tables in the stage schema will be consolidated into a single table in the preload schema. If 'deid' option is selected, deidentification of diagnosis codes will also take place here. Note that  this step involves only tables with subsets (condition_occurrence, procedure_occurrence, drug_exposure, measurement, observation).

    ```bash
    omop_etl preload --all
    ```

    Alternatively, tables can be preloaded individually

    ```bash
    # preload subset res_device from measurement table
    omop_etl preload --table measurement --subset res_device

    # preload all subsets from measurement table
    omop_etl preload --table measurement --subset all
    ```

4. Load. This step involves loading data into OMOP conforming tables. Derived tables observation_period, drug_era, and condition_era are populated during this step.

    ```bash
    omop_etl load --all
    ```

    Alternatively, tables can be loaded individually

    ```bash
    omop_etl load --table <table name>
    ```

5. Fix domains. During this step, records from condition_occurrence, procedure_occurrence, drug_exposure, observation, and measurement will be reallocated to match the domain_id of the standard concept. The table device_exposure is populated during this step with records from procedure_occurrence.

    ```bash
    omop_etl postproc --fix_domains
    ```

    `@Yankuic` I don't see drug_exposure in postprocessing by_domain section of config.yml file, and I don't see corresponding sql file. *drug_exposure only receives records from procedure_occurrence*

    `@Yankuic` Are we sure that only data from procedure_occurrence will be moved to device_exposure table? *so far, yes but i guess this is something we want to keep testing*

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
