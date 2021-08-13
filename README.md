# OMOP ETL

## Preliminaries

> Windows uses back slashes in URL. Therefore, we need to change all back slashes to forward slashes since Git Bash is Linux based.

## Part I. Installation

### Setting up conda environment and installing required libraries

1. Make sure you have Anaconda installed on your system. If not, go to [anaconda.com](https://www.anaconda.com/products/individual) and follow instructions to download and install.

2. Open the command line and create new python environment

    ```bash
    # Create environment named omop_etl
    conda create -n omop_etl python=3.7
    # Activate new environment
    conda activate omop_etl
    ```

3. Install required python libraries

    ```bash
    # Install turbodbc from wheel
    pip install -r //share.ahc.ufl.edu/share$/DSS/IDR_Projects/OMOP/python_env/requirements.txt
    # Install other dependencies from Anaconda repo
    conda install numpy pandas pyodbc selenium sqlalchemy sqlparse pyyaml
    ```

4. Install optional packages

    ```bash
    conda install jupyter jupyterlab
    ```

### Install omop_etl package

Make sure you have Git installed on your system. If not, go to [git-scm.com](https://git-scm.com/download/win) and follow instructions to download and install.

- Launch git bash on the location where the cloned directory will be stored.

- If this is your first time pulling the central Git repository (repo) from IDR shared drive, you need to clone the repo to your local directory first. Otherwise, skip to the next step.

    ```bash
    $ git clone //share.ahc.ufl.edu/Share$/DSS/IDR_Projects/GitRepo/OMOP/omop_etl.git
    Cloning into 'omop_etl'...
    done.
    ```

- Install omop_etl package

    ```bash
    cd omop_etl/

    # Option --record saves the path of all files installed into files.txt. This will make your life easier 
    # if you want to uninstall the package later on.
    python setup.py install --record files.txt
    ```

- Uninstall package

    ```bash
    xargs rm -rf < files.txt
    ```

## Part II. Setting up new OMOP project

1. Create project schema on a blank database

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

2. Load vocabulary tables into project database.

    Vocabulary tables are used to map source codes (ICD, CPT, LOINC, etc.) to OMOP standard concepts.

    - Download vocabulary tables from [Athena](https://athena.ohdsi.org).
    - Unzip and save vocabulary tables into the project vocabulary directory.
    - Load tables from the project vocabulary directory into the project database.

        ```bash
        omop_etl vocab --all
        ```

3. Create new project

    In your project database, you should have schema, empty OMOP standard tables, and vocabulary tables ready.

    ```bash
    omop_etl new_project --path <path to new project> --name <myproject> --server <SQL server url> --database <project database>
    ```

    - example of a OMOP project named 'omop_project1':

        ```bash
        omop_etl new_project -p ./ -n omop_project1 -db dws_cc_omop -s edw.shands.ufl.edu
        ```

    Below is what your project directory will look like after running the 'new project' command. With config.yml, you can customize the project metadata such as cohort file, cohort start/end dates, etc.

    ```bash
    omop_project_dir
    |__config.yml
    |__refresh_cohort.py
    |__vocabulary
        |__source_to_concept_map.csv
    ```

4. Configure new project.

    **config.yml** is the project configuration file that stores all project configuration parameters. This file can be modified to

    - Select BO document names for cohort and stage queries.
    - Set up data refresh date range.
    - Change SQL connection configuration.
    - Select data elements to load.
    - Select the Athena vocabulary set.
    - Select the LOINC code set.

    As a minimum, every project requires cohort and stage BO document names, server url and database name, and date range. If options --server and --database were used in step 3, the connection parameters should be set already in config.yml.

    **refresh_cohort.py** can be modified to use a different date range or a different algorithm to select the patient cohort. This python script, included by default, was developed for COVID data.

    **source_to_concept_map.csv** can be modified to include/exclude custom mappings from source codes to OMOP vocabularies.

## De-identification

## Part III. Using OMOP_ETL comand line interface

All commands must be executed within the omop project directory, where the files config.yml and refresh_cohort.py must exist.

### 3. Refresh cohort

This is to create the cohort table in db.

    $ omop_project1> python refresh_cohort.py

### 4. Staging data. 

Mapping tables will be updated during this step.

    $ omop_project1> omop_etl stage --all

### 5. Preload data. 

This will insert data from subsets into one table.

    $ omop_project1> omop_etl preload --all

### 6. Load data.

    $ omop_project1> omop_etl load --all

### 7. Move records to match domain_id with domain table

    $ omop_project1> omop_etl postproc --fix_domains

### 8. Generate hipaa compliant dataset

- For de-identified dataset run

        $ omop_project1> omop_etl postproc --deid


- For limited dataset run

        $ omop_project1> omop_etl postproc --limited


### 9. Export to csv files

    Not implemented


### Sync local and central repositories

Since we already have a local copy of omop_etl,  in this step I will show you how to stash/commit the changes in our local repo first and then pull the central repo.

There are two ways you can do this: choose option 1 if you don't want your local changes to be mergered; choose option 2 if you wish to upload your changes to central repo.

- Option 1. Stashing your changes into cache. Pulling the the central repo. Unstashing your local changes to avoid conflicts. 
    
        $ git stash
        $ git pull origin master
        $ git unstash

    > 'master' is the branch by default created in git. There could be other bracnhes exist, check with the project administrator for the appropriate branch to work with.

- Option 2. Adding your updates to git. Committing the updates. Pulling the the central repo.
        
        $ git add .
        $ git commit -m 'message you would like to comment on this update'
        $ git pull origin master

    > git add . will add all updates to git, you can also speficy only the files you want to add. 
