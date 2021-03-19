# OMOP ETL

## Description

## Release notes

## Install

- How to install from distribution file.

Write code to create new project.
    - create conf.yml file with project env info.
    - generates project structure for log files, reports, etc.

## Instructions for users

1. Create new project.
2. Configure project.
3. Run etl for new project.

## Instructions for developers

- Add new data elements.

## Best practices

- Do not include derived columns in Business Objects queries. If a data element in BO is derived from another column in the same table do not include it. Instead, derive the values during postprocessing. BO queries with derived variables require more processing time and storage.

## ToDo

- Implement setup.py
- Implement multiprocessing to execute queries.

- Test procedure_occurrence with date earlier than 2018. Check ICD9Proc mappings and row counts.

## Vocabulary mapping

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

## OHDSI Achilles

Some debugging is needed before running Achilles for the first time.

- Correct column name in R installation\library\Achilles\sql\sql_server\validate_schema.sql, qualifier_source_value in line 355 to modifier_source_value.

- Schema validation does not detect if table specimen is missing. This table is needed for analysis 1900. Make sure the table exists in omop cdm schema.

- Required dependencies to run achilles dashboard:
    - shiny
    - shinydashboard
    - tidyr
