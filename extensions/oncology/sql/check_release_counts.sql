/****** Script for SelectTopNRows command from SSMS  ******/
SELECT count(*)
  FROM [DWS_CC_OMOP].[hipaa].condition_occurrence
  where condition_type_concept_id = 32534

SELECT count(*)
  FROM [DWS_CC_OMOP].temp.condition_occurrence_temp

SELECT count(*)
  FROM [DWS_CC_OMOP].[hipaa].measurement
  where measurement_type_concept_id = 32534

SELECT count(*)
  FROM [DWS_CC_OMOP].temp.measurement_temp

SELECT count(*)
  FROM [DWS_CC_OMOP].[hipaa].observation
  where observation_type_concept_id = 32534

SELECT count(*)
  FROM [DWS_CC_OMOP].temp.observation_temp

SELECT count(*)
FROM [DWS_CC_OMOP].[hipaa].episode_event

SELECT count(*)
FROM [DWS_CC_OMOP].temp.episode_event_temp

-- SELECT count(distinct modifier_of_event_id)
-- FROM [DWS_CC_OMOP].[hipaa].measurement
-- where measurement_type_concept_id = 32534

SELECT count(distinct modifier_of_event_id)
FROM [DWS_CC_OMOP].[hipaa].measurement a
LEFT JOIN (
	select distinct condition_occurrence_id 
	from hipaa.condition_occurrence
	where condition_type_concept_id = 32534
) b
on a.modifier_of_event_id = b.condition_occurrence_id
where measurement_type_concept_id = 32534
and modifier_of_event_id is null 
