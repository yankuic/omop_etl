# ISSUES

## June 2021

- [x] Missing concept mappings for non-invasive sbp and dbp
- [x] Null values in measurementsource_value, comming from map - cvp and bp_non-invasive tables

## May 2021

measurement

- [x] We are potentially missing 30m rows. The most significant drop was with RESP RATE, which went from 27.9m to 5.6m. We are also missing 140 LOINC codes loaded in the old version but not in the new, which amount to 7.4m rows.

## procedure_occurrence

- [x] procedure_icd have records with NULL encounters that seems like a duplicate for another record that do have encounter number. Furthermore, records with null encounters are being duplicated on load. I suspect this issue occurs in multiple tables.

    Here's an example

        ```sql
        select * 
        from stage.procedure_icd
        where patient_key = 3977389
        and start_date = '2020-01-03'
        ```

## measurement

- [x] 2021-03-11 - measurement_heartrate. preload table has 2900 more records than stage table.
- [x] 2021-03-11 - measurement_lab. preload table have 35861 less records than stage. Records filtered by distinct clause.
