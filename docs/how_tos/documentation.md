# Instructions for developers

## Working with GitLab

We follow [GitLab Flow](https://docs.gitlab.com/ee/topics/gitlab_flow.html) branching model and issue tracker system for collaborative development. This workflow provides simple heuristics to create and merge branches, track issues, and release package versions.

## BO documents

    Once the data providers are created, Matt will run a query on his end:
    """
    select *
    from DWS_METADATA.dbo.MD_MGMT_WEBI_DATA_PRVDRS_TEST
    where DOC_ID in (
        select DOC_ID
        from DWS_METADATA.dbo.MD_MGMT_WEBI_DOCS_TEST 
        where DOC_NAME = 'omop'
    )
    """
    which can generate the SQL query for each dimension table (dp_name). 

## Creating queries in BO

Do not include derived columns in Business Objects queries. If a data element in BO is derived from another column in the same table do not include it. Instead, derive the values during postprocessing. BO queries with derived variables require more processing time and storage.

Placeholders:

- Start date: 01/01/1900
- End date: 12/21/1900
- LOINC codes: LOINCLIST
- Patient list: 12345678

## Adding a new data element

1. Add new data elements to the corresponding table in config.yml, section load.

    For example, to add res_vent_mode into measurement table add the following entry:

        ```yaml
        load:
            measurement:
            res_vent_mode:
        ```

2. Add short name and dp_name pair in stage section from etl_config file. dp_name is case sensitive.

    Example:

        ```yaml
        stage:
            measurement:
            res_vent_mode: MEASUREMENT_Res_Vent_Mode
        ```

3. Add short name and sql script file name pair in preload section from etl_config file.

    Example:

        ```yaml
        preload:
            measurement:
            res_vent_mode: preload_measurement_res_vent_mode.sql
        ```

4. In the section aliases of the etl_config file, add the aliases list for the columns of the table that will store the new data.

    Example:

        ```yaml
        aliases:
            MEASUREMENT_Res_Vent_Mode:
            - patient_key
            - patnt_encntr_key
            - respiratory_date
            - respiratory_datetime
            - adult_vent_mode
            - attending_provider
            - visit_provider
        ```

## Register load table

Add a new entry under section load with the table name and sql script name. The sql script should be located in the sql folder.

    ```yaml
    load:
        table_name: load_table_script.sql
    ```

Make sure to de-identify the table if applies and to include code to validate it.

## Vocabulary mappings

Source values (icd codes, loic codes, etc.) are mapped to concept_ids during the Load step, then relocated to omop tables using the domain_id.

**Condition ICD codes**. OMOP concept table include ICD(9,10) and ICD(9,10)CM codes. Overlapping occurs between these two coding systems and OMOP includes two entries for the same ICD code, one for each version. Since UFHealth uses ICD CM, codes from condition_occurrence were mapped to ICD(9,10)CM codes. Mapping to ICD was performed only when no equivalent CM exists in OMOP vocabulary.

ICD codes are mapped to SNOMED. ICD codes can be mapped to multiple SNOMED codes. For example, ICD9 249.40 (secondary diabetes mellitus) is mapped to SNOMED 192279 and 195771. As a result, one ICD record can have two or more corresponding SNOMED codes.

The following query return the codes from condition_occurrence mapped to two or more SNOMED codes.

    ```sql
    select * from (
        select distinct 
                concept_code
                ,concept_id_2 
                ,ROW_NUMBER() over (partition by concept_code order by concept_code, concept_id_2) rn
        from (
            select distinct concept_code, concept_id_2
            from stage.condition a
            left join xref.concept d
            on a.diag_cd_decml = d.concept_code and a.icd_type + 'CM' = d.vocabulary_id
            join xref.concept_relationship e
            on d.concept_id = e.concept_id_1 and e.relationship_id = 'Maps to'
        ) x
    ) y
    where rn > 1
    ```

**Procedure ICD codes**. Procedure ICD0PCS codes are standard in OMOP.

v0

Hi Gigi,

We have completed the first refresh of the de-identified covid omop dataset with the new OMOP pipeline. I'm currently exporting the data to csv files but you can access the deid dataset from management studio. The tables ares stored in schema dws_omop.hipaa.*

Please note that this is an imperfect dataset. We still need to run a bunch of validation tests, plus characterizations with Achilles and the OMOP data quality dashboard.

We were expecting to have results for achilles today, but the application failed in analysis 2000. In the mean time, we have some descriptive statistics for each table in schema ...

Some improvements in this release:

1. We've added the BO blood pressure measures missing in previous releases:

    - BP non-invasive.
    - BP
    - CVP

2. Zipcode dates ...

Work in progress and pending issues:

1. We don't have info on the method used for a buch of BP measures. Column BP from BO includes invasive and non-invasive methods. For some records we can retrieve the method used using the column BP_Method, but most rows don't have this info (BP_Method=NULL). Is there another way to determine the method used? If this is not possible, should we map BP values for which we do not know the method to concepts systolic blood pressure (concept id 4154790) and diastolic blood pressure (concept id 4152194)?

2. Run our usual validation scripts and complete characterization with Achilles and OMO dq dashboard.

3. Update vocabulary tables. We have a script to automatically download the vocabularies from athena and then load the csv files into omop database. However, we did not updated the tables since we cannot retrieve CPT4 codes. The NIH changed their api and rendered athena's script to download CP4 codes unusable. We'll need to wait for ohdsi to update their code or come up with our own solution.

4. Data guide. We are working on a data guide similar to what we already have for UFH i2b2. We are still in an early stage, but I expect things will speed up as we move to the validation phase.

Have fun with the data and let mus know if you have any questions.

Yankuic

**Procedure ICD codes**. Procedure ICD0PCS codes are standard in OMOP.

## OHDSI Achilles

Create schemas:

- results
- scratch

Some debugging is needed before running Achilles for the first time.

- Correct column name in R installation\library\Achilles\sql\sql_server\validate_schema.sql, qualifier_source_value in line 355 to modifier_source_value.

- Schema validation does not detect if table specimen is missing. This table is needed for analysis 1900. Make sure the table exists in omop cdm schema.

- Required dependencies to run achilles dashboard:

  - shiny
  - shinydashboard
  - tidyr

- Achilles bug: fails to run heel on multithreading.

--- from readme_juyun ----

## Finished table

    person
    death

## Staging

## 1. Validate objects in current Business Objects(BO) universes - only needed in project initialization

    OMOP_CDM_BO_Mapping.xlsx

## 2. Design data providers in BO that correspond to OMOP data dimension - only needed in project initialization

    - Use the existing obejct in BO universes (Clinical Encounter, Coding Detail) to fit OMOP
    - for the objects that do not exist, work with Neeharika and Joanne to create them.

## 4. Maintain the structure (i.e. column name, sequence of columns) of stage tables in DWS_OMOP

    Since we use the 'insert into select ...' queries to load the data from warehouse to the tables we created above in DWS_OMOP, we need to maintain these table definition in DWS_OMOP database.
    
    The names of the columns should align with the names in BO, so that people can back track the column in BO if OMOP tables appear to be incorrect.

    E.g.

'''sql
DROP TABLE [stage].[PERSON]
CREATE TABLE [stage].[PERSON](
    PATIENT_KEY [int] NOT NULL,  --ALL_PATIENTS.PATNT_KEY
    SEX [varchar](50)  NULL, -- ALL_SEXES.STNDRD_LABEL
    RACE [varchar](50)  NULL, -- ALL_RACES.STNDRD_LABEL
    ETHNICITY [varchar](50)  NULL, --ALL_ETHNIC_GROUPS.STNDRD_LABEL
    ADDR_KEY [int]  NULL, --ALL_ADDRESSES_RECENT.ADDR_KEY
    PATNT_BIRTH_DATETIME [datetime2] NULL, --ALL_PATIENTS.patnt_birth_datetime
    PATIENT_REPORTED_PCP_PROV_KEY [int]  NULL, -- ALL_PROVIDERS_PAT_RPTD_PCP.PROVIDR_KEY
    PATIENT_REPORTED_PRIMARY_DEPT_ID [int]  NULL --ALL_HOSPITAL_ORGANIZATION_PT_PRIM_LOC.DEPT_ID
) ON [fg_user1]
'''

## 5. Create and execute the stored procedures through Python

    Run OMOP_sp.py. Here is what the script will do:
    1. create a stored procedure to read the sql query that reads out BO objects (see above), then save in a dataframe.
    2. customize the stored procedure by passing variables such as patient ids and date.
    3. execute the stored procedure
    Now we finish the staging jobs from EDW databases to 

# Loading

## Person

## Death

- death_date and death_datetime. EPIC death datetime if exists, else Social Security Death Index. EPIC death date is more accurate because data comes from the hospital.

- death_type_concept_id. 32817 when death date comes from EPIC, else 32885.

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
