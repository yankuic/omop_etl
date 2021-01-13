# Finished table:
    person
    death

# Staging

## 1. Validate objects in current Business Objects(BO) universes - only needed in project initialization

    OMOP_CDM_BO_Mapping.xlsx

## 2. Design data providers in BO that correspond to OMOP data dimension - only needed in project initialization

    - Use the existing obejct in BO universes (Clinical Encounter, Coding Detail) to fit OMOP
    - for the objects that do not exist, work with Neeharika and Joanne to create them.

## 3. Read SQL 

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

