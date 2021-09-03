USE [DWS_CC_OMOP]
GO
/****** Object:  StoredProcedure [dbo].[validate_observation]    Script Date: 9/2/2021 11:09:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[validate_observation] 
AS
BEGIN

	IF object_id('valid.observation') IS NOT NULL
		DROP TABLE valid.observation

	select 
		observation_concept_id, 
		observation_source_value, 
		case 
			when observation_source_value = 'Zipcode' then 'zipcode'
			else value_as_string
		end as value_as_string,
		unit_source_value, 
		min(value_as_number) as measure_min, 
		max(value_as_number) as measure_max, 
		AVG(value_as_number) as measure_mean,
		stdev(value_as_number) as measure_stdev,
		min(observation_date) as date_min,
		max(observation_date) as date_max,
		count(DISTINCT visit_occurrence_id) as visit_count,
		count(DISTINCT person_id) as patient_count,
		count(*) as rowcouont,
		sum(case when value_as_number is null then 1 else 0 end ) as null_rowcount
	into valid.observation
	from 
		observation	
	group by  
		observation_concept_id, observation_source_value, unit_source_value, 
		case 
			when observation_source_value = 'Zipcode' then 'zipcode'
			else value_as_string
		end
	order by 
		observation_source_value
	
	END