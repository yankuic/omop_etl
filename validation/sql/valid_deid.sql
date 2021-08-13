/*

*/

--deid race
select count(*)
from ( 
    select race_source_value, count(distinct person_id) n
    from hipaa.person
	group by race_source_value
) a 
where n < 11

--deid ethnicity
select count(*)
from ( 
    select ethnicity_source_value, count(distinct person_id) n
    from hipaa.person
	group by ethnicity_source_value
) a 
where n < 11

--deid birth date
select count(*)
from hipaa.person a 
join dbo.person b 
on a.person_id = b.person_id 
where b.birth_datetime <= convert(date, getdate()-365.25*85)
and a.year_of_birth <> '1800'


--deid patnt_key
select count(*)
from hipaa.person 
where person_source_value is not null

--deid provider table
select count(*)
from hipaa.provider
where provider_name is not null 
or npi is not null 
or dea is not null 
or gender_concept_id is not null 
or provider_source_value is not null

--deid location
select count(*)
from hipaa.location 
where address_1 is not null 
or address_2 is not null 
or city is not null 
or location_source_value is not null 

--deid care_site
select count(*)
from hipaa.care_site
where care_site_name is not null 
or care_site_source_value is not null 
or place_of_service_source_value is not null

--deid date_shift
select count(*)
from hipaa.person a
join dbo.person b
on a.person_id = b.person_id
where a.birth_datetime = b.birth_datetime

select count(*) 
from hipaa.death a 
join dbo.death b 
on a.person_id = b.person_id 
where a.death_date = b.death_date
or a.death_datetime = b.death_datetime

select count(*)
from hipaa.visit_occurrence a
join dbo.visit_occurrence b 
on a.visit_occurrence_id = b.visit_occurrence_id
where a.visit_start_date = b.visit_start_date
or a.visit_start_datetime = b.visit_start_datetime
or a.visit_end_date = b.visit_end_date
or a.visit_end_datetime = b.visit_end_datetime

select count(*)
from hipaa.condition_occurrence a
join dbo.condition_occurrence b 
on a.condition_occurrence_id = b.condition_occurrence_id
where a.condition_start_date = b.condition_start_date
or a.condition_start_datetime = b.condition_start_datetime
or a.condition_end_date = b.condition_end_date
or a.condition_end_datetime = b.condition_end_datetime

select count(*)
from hipaa.procedure_occurrence a 
join dbo.procedure_occurrence b 
on a.procedure_occurrence_id = b.procedure_occurrence_id 
where a.procedure_date = b.procedure_date 
or a.procedure_datetime = b.procedure_datetime

select count(*)
from hipaa.drug_exposure a 
join dbo.drug_exposure b 
on a.drug_exposure_id = b.drug_exposure_id 
where a.drug_exposure_start_date = b.drug_exposure_start_date
or a.drug_exposure_start_datetime = b.drug_exposure_start_datetime 
or a.drug_exposure_end_date = b.drug_exposure_end_date
or a.drug_exposure_end_datetime = b.drug_exposure_end_datetime

select count(*) 
from hipaa.observation a 
join dbo.observation b 
on a.observation_id = b.observation_id 
where a.observation_date = b.observation_date 
or a.observation_datetime = b.observation_datetime

select count(*)
from hipaa.measurement a
join dbo.measurement b 
on a.measurement_id = b.measurement_id
where a.measurement_date = b.measurement_date 
or a.measurement_datetime = b.measurement_datetime

select count(*)
from hipaa.observation_period a 
join dbo.observation_period b 
on a.observation_period_id = b.observation_period_id 
where a.observation_period_start_date = b.observation_period_start_date 
or a.observation_period_end_date = b.observation_period_end_date

select count(*)
from hipaa.device_exposure a 
join dbo.device_exposure b 
on a.device_exposure_id = b.device_exposure_id 
where a.device_exposure_start_date = b.device_exposure_start_date 
or a.device_exposure_start_datetime = b.device_exposure_start_datetime 
or a.device_exposure_end_date = b.device_exposure_end_date
or a.device_exposure_end_datetime = b.device_exposure_end_datetime

--deid zipcode
select count(*) 
from hipaa.observation
where left(value_as_string, 3) in ('036', '059', '102', '202', '203', '204', '205', '369', '556', '692', '753', '772', '821', '823', '878', '879', '884', '893')
and observation_source_value = 'zipcode'

--deid icd
select count(*)
from (
	select condition_source_value
		  ,count(distinct person_id) rc
	from preload.condition_occurrence
	group by condition_source_value
) a
where rc < 11
