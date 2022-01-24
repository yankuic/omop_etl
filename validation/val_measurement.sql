/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [concept_id]
      ,[concept_name]
      ,[domain_id]
      ,[vocabulary_id]
      ,[concept_class_id]
      ,[standard_concept]
      ,[concept_code]
      ,[valid_start_date]
      ,[valid_end_date]
      ,[invalid_reason]
  FROM [xref].[concept]
  where concept_id = 2212731

select * from preload.procedure_occurrence
where procedure_concept_id = 2212430

select patient_key, a.* 
from preload.condition_occurrence a
join xref.person_mapping b
on a.person_id = b.person_id
where condition_concept_id in (4098353)
--and active_ind = 'Y'

select *
from dbo.condition_occurrence
where condition_source_value like '%invasive%'--'C79.%' -- 'Y90.5'-- 'R77.1'-- '796.0'-- 'R71.8','C79.71'
--and patient_key = 2071502

select *
from preload.procedure_occurrence
where procedure_source_value = '95024' --like '796%'-- 'R71.8'

select distinct measurement_concept_id, measurement_source_value
from dbo.measurement
where measurement_source_value like '%Venous%'

select count(*)
from dbo.measurement 
where measurement_source_value is null

--update preload.measurement
--set measurement_source_value = 'CVP - Central Venous Pressure', measurement_concept_id=71420008, measurement_source_concept_id=71420008
--where measurement_source_value is null

--update preload.measurement
--set measurement_source_value = 'CVP mean - Mean Central Venous Pressure', measurement_concept_id=3000333, measurement_source_concept_id=3000333
--where measurement_source_value = 'MAP - Central Venous'

select count(*)
from preload.measurement 
where measurement_source_value is null

select distinct source_table, count(*) N
from preload.measurement
where measurement_source_value is null
group by source_table

select top 1000 *
from preload.measurement a
join dbo.visit_occurrence b
on a.visit_occurrence_id = b.visit_occurrence_id
where a.visit_occurrence_id is null

select top 100000 * 
from dbo.measurement 
where measurement_source_value = 'SOFA - LIVER'
order by person_id, visit_occurrence_id, measurement_datetime

--update hipaa.measurement
--set measurement_source_value = 'BP - Non-invasive SBP',
--measurement_concept_id = 4354252,
--measurement_source_concept_id = 4354252
--where measurement_source_value = 'non-invasive sbp' 

--update hipaa.measurement
--set measurement_source_value = 'BP - Non-invasive DBP',
--measurement_concept_id = 4068414,
--measurement_source_concept_id = 4068414
--where measurement_source_value = 'non-invasive dbp' 

select distinct measurement_concept_id, measurement_source_value 
from preload.measurement
where measurement_concept_id = 0 --source_value = 'non-invasive dbp' 

select distinct measurement_concept_id, measurement_source_value 
from dbo.measurement
where measurement_source_value like '%Vent%' 


--update hipaa.measurement
--set measurement_concept_id = 4068414
--where measurement_source_value = 'BP - Non-invasive DBP'

--update hipaa.measurement
--set measurement_concept_id = 4354252
--where measurement_source_value = 'BP - Non-invasive SBP'


--MEASUREMENT Compare row counts per code with V6 version
select * from 
(select measurement_source_value, count(*) N_current
  from dbo.measurement 
 group by measurement_source_value) a
full outer join (
	select measurement_source_value, count(*) N_v6
	from DWS_COVID_OMOP.dbo.measurement
	group by measurement_source_value
) b
on a.measurement_source_value = b.measurement_source_value
left join (
	select distinct condition_source_value as source_value, 'condition' as source_table from preload.condition_occurrence
	union
	select distinct procedure_source_value as source_value, source_table from preload.procedure_occurrence
	union
	select distinct observation_source_value as source_value, source_table from preload.observation
) c
on c.source_value = a.measurement_source_value


select distinct measurement_source_value 
from dbo.measurement
where measurement_source_value like '%invasive%'


--update dbo.measurement 
--set measurement_source_value = 'BP - Non-invasive DBP'
--where measurement_source_value = 'non-invasive dbp'

--update hipaa.measurement 
--set measurement_source_value = 'BP - Non-invasive DBP'
--where measurement_source_value = 'non-invasive dbp'


--OBSERVATION
select * from 
(select observation_source_value, count(*) N_current
  from dbo.observation 
 group by observation_source_value) a
full outer join (
	select observation_source_value, count(*) N_v6
	from DWS_COVID_OMOP.dbo.observation
	group by observation_source_value
) b
on a.observation_source_value = b.observation_source_value
left join (
	select distinct condition_source_value as source_value, 'condition' as source_table from preload.condition_occurrence
	union
	select distinct procedure_source_value as source_value, source_table from preload.procedure_occurrence
	union
	select distinct measurement_source_value as source_value, source_table from preload.measurement
) c
on c.source_value = a.observation_source_value
left join (
	select x.concept_code, x.concept_name, xx.domain_id, xx.standard_concept, relationship_id 
	from xref.concept x
	join xref.concept_relationship y
	on x.concept_id = y.concept_id_1
	join xref.concept xx
	on xx.concept_id = y.concept_id_2
	where y.relationship_id = 'maps to'
	and xx.domain_id = 'observation'
) z
on a.observation_source_value = z.concept_code
--where a.observation_source_value = 'V03.90XA'
order by source_value, N_current


select distinct condition_concept_id, domain_id, b.concept_code, concept_class_id
from dbo.condition_occurrence a
join xref.concept b
on a.condition_concept_id = b.concept_id
where condition_source_value not in (select distinct condition_source_value from preload.condition_occurrence)


select top 1000 * from xref.concept
where concept_id =35225557


--Verify dateshift

select distinct a.person_id, a.death_date, b.observation_date, b.observation_source_value 
from hipaa.death a
left join hipaa.observation b
on a.person_id = b.person_id
where a.death_date < b.observation_date
--and a.person_id = 392
order by a.person_id 

select distinct a.person_id, a.death_date, b.observation_date, b.observation_source_value 
from dbo.death a
left join dbo.observation b
on a.person_id = b.person_id
where a.death_date < b.observation_date
--and a.person_id = 392
order by a.person_id 

select b.[person_id]
      ,[death_date] = ISNULL(a.PATNT_DTH_DATE, a.PATNT_SSN_DTH_DATE)
      ,[death_datetime] = ISNULL(a.PATNT_DTH_DATE, a.PATNT_SSN_DTH_DATE)
      ,[death_type_concept_id] = CASE WHEN a.PATNT_DTH_DATE IS NULL THEN 32885 ELSE 32817 END
	  ,a.PATNT_DTH_DATE, a.PATNT_SSN_DTH_DATE
      ,[cause_concept_id] = 0
      ,[cause_source_value] = NULL
      ,[cause_source_concept_id] = 0
  from stage.death a
  join xref.person_mapping b
  on a.PATIENT_KEY = b.patient_key
where b.active_ind = 'Y'
and person_id in (59, 141, 180, 257) 
--order by person_id 

select *
from stage.DEATH a
join stage.OBSERVATION_Payer b
on a.patient_key = b.patient_key
where isnull(a.patnt_dth_date, a.patnt_ssn_dth_date) < b.encounter_effective_date

select top 100 *
from stage.death a
join xref.person_mapping b
on a.patient_key = b.patient_key
join preload.measurement c
on b.person_id = c.person_id
where isnull(a.patnt_dth_date, a.patnt_ssn_dth_date) < measurement_date





