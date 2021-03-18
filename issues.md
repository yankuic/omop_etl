# ISSUES

## procedure_occurrence

- procedure_icd have records with NULL encounters that seems like a duplicate for another record that do have encounter number. Furthermore, records with null encounters are being duplicated on load.

Here's an example

    ```sql
    select * 
    from stage.procedure_icd
    where patient_key = 3977389
    and start_date = '2020-01-03'
    ```

I suspect this issue occurs in multiple tables.

## measurement

- [ ] 2021-03-11 - measurement_heartrate. preload table has 2900 more records than stage table.
- [x] 2021-03-11 - measurement_lab. preload table have 35861 less records than stage. Records filtered by distinct clause.
- [ ] 2021-03-12 - text in value_source_value is explicitly truncated to len 50.
- [ ] 2021-03-12 - measurement_painscale, 3981689 missing on preload.
