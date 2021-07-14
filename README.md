# OMOP ETL

## Part I. Install Git and Download (or 'pull' in Git's term) Python Library.

### 1. Check to see if you have Anaconda on your device. If not, you will need to install Anaconda first. To download Anaconda, please go to https://www.anaconda.com/products/individual. 

### 2. Check to see if you have Git on your device. If not, you will need to install Git first. To download Git, please go to https://git-scm.com/download/win (Windows).


### 3. If this is your first time pulling the central Git repository (repo) from IDR shared drive, then you need to clone the repo to your local directory first. Otherwise, skip to the next step.

- Change the current working directory to the location where you want the cloned directory.
- Open Git Bash.
- Type git clone, and then paste the URL of the central repo.

        $ git clone //share.ahc.ufl.edu/Share$/DSS/IDR_Projects/GitRepo/OMOP/omop_etl.git

    > Windows uses back slashes in URL. Therefore, we need to change all back slashes to forward slashes since Git Bash is Linux based.
- When the pulling is done, you should see:
    
        $ Cloning into 'omop_etl'...
        done.


### 4. Since we already have a local copy of omop_etl,  in this step I will show you how to stash/commit the changes in our local repo first and then pull the central repo.

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


## Part II. Install/re-install OMOP_ETL

### 1. To install or re-install omop_etl package, go to the omop_etl folder. Open a Git Bash command line window, and type in command as follows to run setup.py: 

    $ python setup.py install --record files.txt

> files.txt keeps the installation records.

### 2. Use omop_etl to create new project.

(*Not implemented*) Create project schema for your OMOP project.
    
    $ omop_etl create_schema

(*Not implemented*) Load vocabulary tables

> Vocabulary tables are used to map customed concepts to OMOP standard concepts. Currently, only the 'source_to_concept_map' exists.

Create the new project.

> In your project database, you should have schema, empty OMOP standard tables, and vocabulary tables ready. 

- template
        
        $ omot_etl new_project -p <path to my new project> -n <myproject> -db <project database> -s <server>

- example of a OMOP project named 'omop_project1': 

        $ omop_etl new_project -p ./ -n omop_project1 -db dws_cc_omop -s edw.shands.ufl.edu

### 3. Now you have successfully installed omop_etl package.

Below is what your project directory will look like after running the 'new project' command. With config.yml, you can customize the project metadata such as cohort file, cohort start/end dates, etc. 

        omop_project_dir
        |__config.yml
        |__refresh_cohort.py
        |__vocabulary

> All commands must be executed within the omop project directory, where the files config.yml and refresh_cohort.py must exist. 

## Part III. ETL Steps Using OMOP_ETL

### 1. Overview of db schemas that will be generated by omop_etl:

    Vocabulary tables are in xref schema.
    Mapping tables are in xref schema.
    Raw data are in stage schema.
    Pre-processed data is in preload schema.
    Postprocessed tables are in dbo schema.

### 2. Configure project.

Navigate to omop project directory.

    $ cd omop_project1


### 3. Refresh cohort. 

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

