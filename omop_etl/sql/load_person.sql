/****** Script for SelectTopNRows command from SSMS  ******/
truncate table dbo.person
insert into dbo.person 
select distinct 
      b.[person_id]
      ,[gender_concept_id] = g.target_concept_id
      ,[year_of_birth] = YEAR(a.patnt_birth_datetime)
      ,[month_of_birth] = MONTH(a.patnt_birth_datetime)
      ,[day_of_birth] = DAY(a.patnt_birth_datetime)
      ,[birth_datetime] = a.patnt_birth_datetime
      ,[race_concept_id] = h.target_concept_id
      ,[ethnicity_concept_id] = f.target_concept_id
      ,[location_id] = e.location_id
      ,[provider_id] = c.provider_id
      ,[care_site_id]  = d.care_site_id
      ,[person_source_value] = a.patient_key
      ,[gender_source_value] = a.sex
      ,[gender_source_concept_id] = 0
      ,[race_source_value] = a.race
      ,[race_source_concept_id] = 0
      ,[ethnicity_source_value] = a.ethnicity
      ,[ethnicity_source_concept_id] = 0
from stage.person a
join xref.person_mapping b
on a.patient_key = b.patient_key
left join xref.provider c
on a.PATIENT_REPORTED_PCP_PROV_KEY = c.provider_source_value
left join xref.care_site d
on cast(a.dept_id as varchar(50)) = d.care_site_source_value
left join xref.location e
on a.addr_key = e.location_source_value
left join xref.source_to_concept_map f 
on a.ETHNICITY = f.source_code and f.source_vocabulary_id = 'ethnicity'
left join xref.source_to_concept_map g 
on a.SEX = g.source_code and g.source_vocabulary_id = 'sex'
left join xref.source_to_concept_map h
on a.RACE = h.source_code and h.source_vocabulary_id = 'race'
where a.patnt_birth_datetime is not null 
and h.target_concept_id is not null 
and f.target_concept_id is not null 
and b.active_ind = 'Y'
