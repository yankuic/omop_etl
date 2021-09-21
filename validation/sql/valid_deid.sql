/*

*/

--deid race
select test = 'masked race_source_value with less than 11 patients.', test_dt = getdate(), (case when count(*) = 0 then 'PASSED' else 'FAILED' end) result
from ( 
    select race_source_value, count(distinct person_id) n
    from hipaa.person
	group by race_source_value
) a 
where n < 11

union
select test = 'masked race_concept_id with less than 11 patients', test_dt = getdate(), (case when count(*) = 0 then 'PASSED' else 'FAILED' end) result
from ( 
    select race_concept_id, count(distinct person_id) n
    from hipaa.person
	group by race_concept_id
) a 
where n < 11

union
select test = 'masked race_source_concept_id with less than 11 patients', test_dt = getdate(), (case when count(*) = 0 then 'PASSED' else 'FAILED' end) result
from ( 
    select race_source_concept_id, count(distinct person_id) n
    from hipaa.person
	group by race_source_concept_id
) a 
where n < 11

--deid ethnicity
union
select test = 'masked ethnicity_source_value with less than 11 patients', test_dt = getdate(), (case when count(*) = 0 then 'PASSED' else 'FAILED' end) result
from ( 
    select ethnicity_source_value, count(distinct person_id) n
    from hipaa.person
	group by ethnicity_source_value
) a 
where n < 11

union
select test = 'masked ethnicity_concept_id with less than 11 patients', test_dt = getdate(), (case when count(*) = 0 then 'PASSED' else 'FAILED' end) result
from ( 
    select ethnicity_concept_id, count(distinct person_id) n
    from hipaa.person
	group by ethnicity_concept_id
) a 
where n < 11

union
select test = 'masked ethnicity_source_concept_id with less than 11 patients', test_dt = getdate(), (case when count(*) = 0 then 'PASSED' else 'FAILED' end) result
from ( 
    select ethnicity_source_concept_id, count(distinct person_id) n
    from hipaa.person
	group by ethnicity_source_concept_id
) a 
where n < 11

--deid birth date
--this test may fail if its run on a later date than the date of the data refresh.
union
select test = 'masked birth_datetime for patients older than 85 y.', test_dt = getdate(), (case when count(*) = 0 then 'PASSED' else 'FAILED' end) result
from hipaa.person a 
join dbo.person b 
on a.person_id = b.person_id 
where b.birth_datetime <= convert(date, getdate()-365.25*85)
and a.year_of_birth <> '1800'

--deid patnt_key
union
select test = 'person_source_value is null', test_dt = getdate(), (case when count(*) = 0 then 'PASSED' else 'FAILED' end) result
from hipaa.person 
where person_source_value is not null

--deid provider table
union
select test = 'provider name, gender, birth year, and ids set to null', test_dt = getdate(), (case when count(*) = 0 then 'PASSED' else 'FAILED' end) result
from hipaa.provider
where provider_name is not null 
or year_of_birth is not null
or npi is not null 
or dea is not null 
or gender_concept_id is not null 
or provider_source_value is not null
or gender_source_value is not null

--deid location
union
select test = 'location address info is null', test_dt = getdate(), (case when count(*) = 0 then 'PASSED' else 'FAILED' end) result
from hipaa.location 
where address_1 is not null 
or address_2 is not null 
or city is not null 
or location_source_value is not null 
or county is not null

--deid care_site
union
select test = 'care_site name and ids set to null', test_dt = getdate(), (case when count(*) = 0 then 'PASSED' else 'FAILED' end) result
from hipaa.care_site
where care_site_name is not null 
or care_site_source_value is not null 
or place_of_service_source_value is not null
or place_of_service_concept_id is not null

--deid date_shift
union
select test = 'patient birthdate is shifted', test_dt = getdate(), (case when count(*) = 0 then 'PASSED' else 'FAILED' end) result
from hipaa.person a
join dbo.person b
on a.person_id = b.person_id
where a.birth_datetime = b.birth_datetime

union
select test = 'patient death_date is shifted', test_dt = getdate(), (case when count(*) = 0 then 'PASSED' else 'FAILED' end) result 
from hipaa.death a 
join dbo.death b 
on a.person_id = b.person_id 
where a.death_date = b.death_date
or a.death_datetime = b.death_datetime

union
select test = 'visit dates are shifted', test_dt = getdate(), (case when count(*) = 0 then 'PASSED' else 'FAILED' end) result
from hipaa.visit_occurrence a
join dbo.visit_occurrence b 
on a.visit_occurrence_id = b.visit_occurrence_id
where a.visit_start_date = b.visit_start_date
or a.visit_start_datetime = b.visit_start_datetime
or a.visit_end_date = b.visit_end_date
or a.visit_end_datetime = b.visit_end_datetime

union
select test = 'condition_occurrence dates are shifted', test_dt = getdate(), (case when count(*) = 0 then 'PASSED' else 'FAILED' end) result
from hipaa.condition_occurrence a
join dbo.condition_occurrence b 
on a.condition_occurrence_id = b.condition_occurrence_id
where a.condition_start_date = b.condition_start_date
or a.condition_start_datetime = b.condition_start_datetime
or a.condition_end_date = b.condition_end_date
or a.condition_end_datetime = b.condition_end_datetime

union
select test = 'procedure_occurrence dates are shifted', test_dt = getdate(), (case when count(*) = 0 then 'PASSED' else 'FAILED' end) result
from hipaa.procedure_occurrence a 
join dbo.procedure_occurrence b 
on a.procedure_occurrence_id = b.procedure_occurrence_id 
where a.procedure_date = b.procedure_date 
or a.procedure_datetime = b.procedure_datetime

union
select test = 'drug_exposure dates are shifted', test_dt = getdate(), (case when count(*) = 0 then 'PASSED' else 'FAILED' end) result
from hipaa.drug_exposure a 
join dbo.drug_exposure b 
on a.drug_exposure_id = b.drug_exposure_id 
where a.drug_exposure_start_date = b.drug_exposure_start_date
or a.drug_exposure_start_datetime = b.drug_exposure_start_datetime 
or a.drug_exposure_end_date = b.drug_exposure_end_date
or a.drug_exposure_end_datetime = b.drug_exposure_end_datetime

union
select test = 'observation dates are shifted', test_dt = getdate(), (case when count(*) = 0 then 'PASSED' else 'FAILED' end) result 
from hipaa.observation a 
join dbo.observation b 
on a.observation_id = b.observation_id 
where a.observation_date = b.observation_date 
or a.observation_datetime = b.observation_datetime

union
select test = 'measurement dates are shifted', test_dt = getdate(), (case when count(*) = 0 then 'PASSED' else 'FAILED' end) result
from hipaa.measurement a
join dbo.measurement b 
on a.measurement_id = b.measurement_id
where a.measurement_date = b.measurement_date 
or a.measurement_datetime = b.measurement_datetime

union
select test = 'observation_period dates are shifted', test_dt = getdate(), (case when count(*) = 0 then 'PASSED' else 'FAILED' end) result
from hipaa.observation_period a 
join dbo.observation_period b 
on a.observation_period_id = b.observation_period_id 
where a.observation_period_start_date = b.observation_period_start_date 
or a.observation_period_end_date = b.observation_period_end_date

union
select test = 'device_exposure dates are shifted', test_dt = getdate(), (case when count(*) = 0 then 'PASSED' else 'FAILED' end) result
from hipaa.device_exposure a 
join dbo.device_exposure b 
on a.device_exposure_id = b.device_exposure_id 
where a.device_exposure_start_date = b.device_exposure_start_date 
or a.device_exposure_start_datetime = b.device_exposure_start_datetime 
or a.device_exposure_end_date = b.device_exposure_end_date
or a.device_exposure_end_datetime = b.device_exposure_end_datetime

--deid zipcode
--codes for these 3d-zipcodes should be null
union
select test = 'masked observation zipcodes for zctas with population less than 20k', test_dt = getdate(), (case when count(*) = 0 then 'PASSED' else 'FAILED' end) result
from hipaa.observation
where left(value_as_string, 3) in ('036', '059', '102', '202', '203', '204', '205', '369', '556', '692', '753', '772', '821', '823', '878', '879', '884', '893')
and observation_source_value = 'zipcode'

union
select test = 'masked location zipcodes for zctas with population less than 20k', test_dt = getdate(), (case when count(*) = 0 then 'PASSED' else 'FAILED' end) result 
from hipaa.location
where left(zip, 3) in ('036', '059', '102', '202', '203', '204', '205', '369', '556', '692', '753', '772', '821', '823', '878', '879', '884', '893')

--all zipcodes should be 3d-zipcodes
union
select test = 'only 3-digit observation zipcodes', test_dt = getdate(), (case when count(*) = 0 then 'PASSED' else 'FAILED' end) result
from hipaa.observation
where len(value_as_string) > 3
and observation_source_value = 'zipcode'

union
select test = 'only 3-digit location zipcodes', test_dt = getdate(), (case when count(*) = 0 then 'PASSED' else 'FAILED' end) result
from hipaa.location
where len(zip) > 3

--3d-zipcodes with less than 11 patients should be null
union
select test = 'masked 3-digit observation zipcodes with less than 11 patients', test_dt = getdate(), (case when count(*) = 0 then 'PASSED' else 'FAILED' end) result
from (
	select value_as_string
		  ,count(distinct person_id) rc
	from hipaa.observation
	where observation_source_value = 'zipcode'
	group by value_as_string
) a
where rc < 11

union
select test = 'masked 3-digit location zipcodes with less than 11 patients', test_dt = getdate(), (case when count(*) = 0 then 'PASSED' else 'FAILED' end) result
from (
	select zip
		  ,count(distinct person_id) rc
	from hipaa.location a
	join hipaa.person b
	on a.location_id = b.location_id
	group by zip
) a
where rc < 11

--deid icd
union
select test = 'masked condition_occurrence ICD codes with less than 11 patients', test_dt = getdate(), (case when count(*) = 0 then 'PASSED' else 'FAILED' end) result
from (
	select condition_source_value
		  ,count(distinct person_id) rc
	from preload.condition_occurrence
	group by condition_source_value
) a
where rc < 11

--deid era tables
union 
select test = 'condition_era dates are shifted', test_dt = getdate(), (case when count(*) = 0 then 'PASSED' else 'FAILED' end) result
from hipaa.condition_era a 
join dbo.condition_era b 
on a.condition_era_id = b.condition_era_id 
where a.condition_era_start_date = b.condition_era_start_date
and a.condition_era_end_date = b.condition_era_end_date

union 
select test = 'drug_era dates are shifted', test_dt = getdate(), (case when count(*) = 0 then 'PASSED' else 'FAILED' end) result
from hipaa.drug_era a 
join dbo.drug_era b 
on a.drug_era_id = b.drug_era_id 
where a.drug_era_start_date = b.drug_era_start_date
and a.drug_era_end_date = b.drug_era_end_date
