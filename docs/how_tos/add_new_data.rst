Adding New Data Elements
========================

BO documents
------------

    Once the data providers are created, Matt will run a query on his end:

    .. code-block:: sql

        select *
        from DWS_METADATA.dbo.MD_MGMT_WEBI_DATA_PRVDRS_TEST
        where DOC_ID in (
            select DOC_ID
            from DWS_METADATA.dbo.MD_MGMT_WEBI_DOCS_TEST 
            where DOC_NAME = 'omop'
        )

    which can generate the SQL query for each dimension table (dp_name). 

Creating queries in BO
----------------------

Do not include derived columns in Business Objects queries. If a data element in BO is derived from another column in the same table do not include it. Instead, derive the values during postprocessing. BO queries with derived variables require more processing time and storage.

Placeholders:

* Start date: 01/01/1900
* End date: 12/21/1900
* LOINC codes: LOINCLIST
* Patient list: 12345678

Adding a new data element
-------------------------

1. Add new data elements to the corresponding table in config.yml, section load.

    For example, to add res_vent_mode into measurement table add the following entry:

    .. code-block:: yaml
    
        load:
            measurement:
            res_vent_mode:
    

2. Add short name and dp_name pair in stage section from etl_config file. dp_name is case sensitive.

    Example:

    .. code-block:: yaml

        stage:
            measurement:
            res_vent_mode: MEASUREMENT_Res_Vent_Mode

3. Add short name and sql script file name pair in preload section from etl_config file.

    Example:

    .. code-block:: yaml

        preload:
            measurement:
            res_vent_mode: preload_measurement_res_vent_mode.sql

4. In the section aliases of the etl_config file, add the aliases list for the columns of the table that will store the new data.

    Example:

    .. code-block:: yaml

        aliases:
            MEASUREMENT_Res_Vent_Mode:
            - patient_key
            - patnt_encntr_key
            - respiratory_date
            - respiratory_datetime
            - adult_vent_mode
            - attending_provider
            - visit_provider

Register load table
-------------------

Add a new entry under section load with the table name and sql script name. The sql script should be located in the sql folder.

    .. code-block:: yaml

        load:
            table_name: load_table_script.sql

Make sure to de-identify the table if applies and to include code to validate it.

Vocabulary mappings
-------------------

Source values (icd codes, loic codes, etc.) are mapped to concept_ids during the Load step, then relocated to omop tables using the domain_id.

**Condition ICD codes**. OMOP concept table include ICD(9,10) and ICD(9,10)CM codes. Overlapping occurs between these two coding systems and OMOP includes two entries for the same ICD code, one for each version. Since UFHealth uses ICD CM, codes from condition_occurrence were mapped to ICD(9,10)CM codes. Mapping to ICD was performed only when no equivalent CM exists in OMOP vocabulary.

ICD codes are mapped to SNOMED. ICD codes can be mapped to multiple SNOMED codes. For example, ICD9 249.40 (secondary diabetes mellitus) is mapped to SNOMED 192279 and 195771. As a result, one ICD record can have two or more corresponding SNOMED codes.

The following query return the codes from condition_occurrence mapped to two or more SNOMED codes.

    .. code-block:: sql

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

**Procedure ICD codes**. Procedure ICD0PCS codes are standard in OMOP.

