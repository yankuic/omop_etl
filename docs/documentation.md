# Instructions for developers

- Add new data elements.

## Creating queries in BO

Do not include derived columns in Business Objects queries. If a data element in BO is derived from another column in the same table do not include it. Instead, derive the values during postprocessing. BO queries with derived variables require more processing time and storage.

Placeholders:

- Start date: 01/01/1900
- End date: 12/21/1900
- LOINC codes: LOINCLIST
- Patient list: 12345678

## ToDo

- [x] Implement setup.py
- [ ] Implement multiprocessing to execute queries.
- [ ] Test procedure_occurrence with date earlier than 2018. Check ICD9Proc mappings and row counts.

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
