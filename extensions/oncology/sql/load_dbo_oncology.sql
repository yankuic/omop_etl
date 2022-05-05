/***** INSERT TEMP TABLES *****/
USE [DWS_CC_OMOP];

BEGIN TRANSACTION;

--Remove tumor registry records (concept_id=32534)
DELETE FROM 
  condition_occurrence 
WHERE 
  condition_type_concept_id = 32534;

DELETE FROM 
  measurement 
WHERE 
  measurement_type_concept_id = 32534;

DELETE FROM 
  drug_exposure 
WHERE 
  drug_type_concept_id = 32534;

DELETE FROM 
  procedure_occurrence 
WHERE 
  procedure_type_concept_id = 32534;

DELETE FROM 
  observation 
WHERE 
  observation_type_concept_id = 32534;

--remove episode data
DELETE FROM 
  fact_relationship 
WHERE 
  domain_concept_id_1 = 32527;

DELETE FROM 
  episode;

DELETE FROM 
  episode_event;

DELETE FROM 
  xref.cdm_source_provenance;

DELETE FROM
  metadata;


-- Load into condition_occurrence
SET IDENTITY_INSERT condition_occurrence ON; --required if IDENTIY is on condition_occurrence_id
INSERT INTO condition_occurrence (
	condition_occurrence_id						
	, person_id
	, condition_concept_id
	, condition_start_date
	, condition_start_datetime
	, condition_end_date
	, condition_end_datetime
	, condition_type_concept_id
	, stop_reason
	, provider_id
	, visit_occurrence_id
	--, visit_detail_id
	, condition_source_value
	, condition_source_concept_id
	, condition_status_source_value
	, condition_status_concept_id
)
SELECT condition_occurrence_id
	, person_id
    , condition_concept_id
    , condition_start_date
    , condition_start_datetime
    , condition_end_date
    , condition_end_datetime
    , condition_type_concept_id
    , stop_reason
    , provider_id
    , visit_occurrence_id
    --, visit_detail_id
    , condition_source_value
    , condition_source_concept_id
    , condition_status_source_value
    , condition_status_concept_id
FROM temp.condition_occurrence_temp;
SET IDENTITY_INSERT condition_occurrence OFF;


INSERT INTO xref.cdm_source_provenance (
	 cdm_event_id
	,cdm_field_concept_id
	,record_id
)
SELECT condition_occurrence_id
    , 1147127   --condition_occurrence.condition_occurrence_id
    , record_id
FROM temp.condition_occurrence_temp;


--Step 18: Move episode_temp into episode
SET IDENTITY_INSERT episode ON;
INSERT INTO episode (
	episode_id		   
	, person_id
	, episode_concept_id
	, episode_start_datetime
	, episode_end_datetime
	, episode_parent_id
	, episode_number
	, episode_object_concept_id
	, episode_type_concept_id
	, episode_source_value
	, episode_source_concept_id
)
SELECT	episode_id 
	, person_id
	, episode_concept_id
	, episode_start_datetime
	, episode_end_datetime
	, episode_parent_id
	--  , episode_number
	--  , record_id
	, 0 -- TOOD: What are we putting here? record_id cannot be inserted as it contains text characters
	, episode_object_concept_id
	, episode_type_concept_id
	, episode_source_value
	, episode_source_concept_id
FROM temp.episode_temp
SET IDENTITY_INSERT episode OFF;

-- Move procedure_occurrence_temp into procedure_occurrence
SET IDENTITY_INSERT procedure_occurrence ON;
INSERT INTO procedure_occurrence (
	procedure_occurrence_id					
	, person_id
	, procedure_concept_id
	, procedure_date
	, procedure_datetime
	, procedure_type_concept_id
	, modifier_concept_id
	, quantity
	, provider_id
	, visit_occurrence_id
	, visit_detail_id
	, procedure_source_value
	, procedure_source_concept_id
	, modifier_source_value
)
SELECT procedure_occurrence_id
	, person_id
    , procedure_concept_id
    , procedure_date
    , procedure_datetime
    , procedure_type_concept_id
    , COALESCE(modifier_concept_id, 0)
    , quantity
    , provider_id
    , visit_occurrence_id
    , visit_detail_id
    , procedure_source_value
    , procedure_source_concept_id
    , modifier_source_value
FROM temp.procedure_occurrence_temp;
SET IDENTITY_INSERT procedure_occurrence OFF;											 


INSERT INTO xref.cdm_source_provenance (
	  cdm_event_id
	, cdm_field_concept_id
	, record_id
)
SELECT procedure_occurrence_id
    , 1147082   --procedure_occurrence.procedure_occurrence_id
    , record_id
FROM temp.procedure_occurrence_temp;


--Move drug_exposure_temp into drug_exposure
SET IDENTITY_INSERT drug_exposure ON;									 
INSERT INTO drug_exposure (
	drug_exposure_id				 
	, person_id
	, drug_concept_id
	, drug_exposure_start_date
	, drug_exposure_start_datetime
	, drug_exposure_end_date
	, drug_exposure_end_datetime
	, verbatim_end_date
	, drug_type_concept_id
	, stop_reason
	, refills
	, quantity
	, days_supply
	, sig
	, route_concept_id
	, lot_number
	, provider_id
	, visit_occurrence_id
	, visit_detail_id
	, drug_source_value
	, drug_source_concept_id
	, route_source_value
	, dose_unit_source_value
)
SELECT drug_exposure_id
	, person_id
    , 0 --We are hardcoding to 0
    , drug_exposure_start_date
    , drug_exposure_start_datetime
    , drug_exposure_end_date
    , drug_exposure_end_datetime
    , verbatim_end_date
    , drug_type_concept_id
    , stop_reason
    , refills
    , quantity
    , days_supply
    , sig
    , COALESCE(route_concept_id,0)
    , lot_number
    , provider_id
    , visit_occurrence_id
    , visit_detail_id
    , drug_source_value
    , drug_source_concept_id
    , route_source_value
    , dose_unit_source_value
FROM temp.drug_exposure_temp;
SET IDENTITY_INSERT drug_exposure OFF;									  


INSERT INTO xref.cdm_source_provenance (
	  cdm_event_id
	, cdm_field_concept_id
	, record_id
)
SELECT drug_exposure_id
    , 1147094   --drug_exposure.drug_exposure_id
    , record_id
FROM temp.drug_exposure_temp;


-- Move episode_event_temp into episode_event
INSERT INTO episode_event (
	  episode_id
	, event_id
	, episode_event_field_concept_id
)
SELECT episode_id
    , event_id
    , episode_event_field_concept_id
FROM temp.episode_event_temp;


-- Move measurement_temp into measurement
SET IDENTITY_INSERT measurement ON;								   
INSERT INTO measurement (
	measurement_id				 
	, person_id
	, measurement_concept_id
	, measurement_date
	, measurement_time
	, measurement_datetime
	, measurement_type_concept_id
	, operator_concept_id
	, value_as_number
	, value_as_concept_id
	, unit_concept_id
	, range_low
	, range_high
	, provider_id
	, visit_occurrence_id
	, visit_detail_id
	, measurement_source_value
	, measurement_source_concept_id
	, unit_source_value
	, value_source_value
	, modifier_of_event_id
	, modifier_of_field_concept_id
)
SELECT
	measurement_id				 
	, person_id
	, measurement_concept_id
	, measurement_date
	, measurement_time
	, measurement_datetime
	, measurement_type_concept_id
	, operator_concept_id
	, value_as_number
	, value_as_concept_id
	, unit_concept_id
	, range_low
	, range_high
	, provider_id
	, visit_occurrence_id
	, visit_detail_id
	, measurement_source_value
	, measurement_source_concept_id
	, unit_source_value
	, value_source_value
	, modifier_of_event_id
	, modifier_of_field_concept_id
FROM temp.measurement_temp;
SET IDENTITY_INSERT measurement OFF;									


INSERT INTO xref.cdm_source_provenance (
	  cdm_event_id
	, cdm_field_concept_id
	, record_id
)
SELECT measurement_id
    , 1147138   --measurement.measurement_id
    , record_id
FROM temp.measurement_temp;


-- move from observation_temp to observation
SET IDENTITY_INSERT observation ON;								   
INSERT INTO observation (
	observation_id				 
	, person_id
	, observation_concept_id
	, observation_date
	, observation_datetime
	, observation_type_concept_id
	, value_as_number
	, value_as_string
	, value_as_concept_id
	, qualifier_concept_id
	, unit_concept_id
	, provider_id
	, visit_occurrence_id
	, visit_detail_id
	, observation_source_value
	, observation_source_concept_id
	, unit_source_value
	, qualifier_source_value
	-- , observation_event_id
	-- , obs_event_field_concept_id
	-- , value_as_datetime
)
SELECT
	observation_id				 
	, person_id
	, observation_concept_id
	, observation_date
	, observation_datetime
	, observation_type_concept_id
	, value_as_number
	, left(value_as_string, 60)
	, value_as_concept_id
	, qualifier_concept_id
	, unit_concept_id
	, provider_id
	, visit_occurrence_id
	, visit_detail_id
	, observation_source_value
	, observation_source_concept_id
	, unit_source_value
	, qualifier_source_value
	-- , observation_event_id
	-- , obs_event_field_concept_id
	-- , value_as_datetime
FROM temp.observation_temp;
SET IDENTITY_INSERT observation OFF;									


INSERT INTO xref.cdm_source_provenance (
      cdm_event_id
    , cdm_field_concept_id
    , record_id
)
SELECT observation_id
    , 1147165   --observaton.observation_id
    , record_id
FROM temp.observation_temp;


-- move from fact_relationship_temp to fact_relationship
INSERT INTO fact_relationship
(
	domain_concept_id_1
	, fact_id_1
	, domain_concept_id_2
	, fact_id_2
	, relationship_concept_id
)
SELECT
	domain_concept_id_1
	, fact_id_1
	, domain_concept_id_2
	, fact_id_2
	, relationship_concept_id
FROM temp.fact_relationship_temp;


-- Observation period
INSERT INTO temp.observation_period_temp	(
	observation_period_id					  
	, person_id
	, observation_period_start_date
	, observation_period_end_date
	, period_type_concept_id
)
SELECT  COALESCE((SELECT MAX(observation_period_id) FROM temp.observation_period_temp)
 ,(SELECT MAX(observation_period_id) FROM observation_period)
 ,0) + row_number() over (order by obs_dates.person_id)         AS observation_period_id																					  
	, obs_dates.person_id				  
   	, obs_dates.min_date as observation_period_start_date
   	, COALESCE(ndp.max_date, obs_dates.max_date) as observation_period_end_date
   	, 44814724 AS period_type_concept_id -- TODO. 44814724-"Period covering healthcare encounters"
FROM 
-- start date -> find earliest record
(
	SELECT person_id,
		 MIN(min_date) AS min_date
		,MAX(max_date) as max_date
	FROM
	(
		SELECT person_id
			, Min(condition_start_date)  min_date
			, MAX(condition_start_date)  max_date
		FROM condition_occurrence
		GROUP BY person_id
	UNION
		SELECT person_id
			, Min(drug_exposure_start_date)
			, Max(drug_exposure_start_date)
		FROM drug_exposure
		GROUP BY person_id
	UNION
		SELECT person_id
			, Min(procedure_date)
			, Max(procedure_date)
		FROM procedure_occurrence
		GROUP BY person_id
	UNION
		SELECT person_id
			, Min(observation_date)
			, Max(observation_date)
		FROM Observation
		GROUP BY person_id
	UNION
		SELECT person_id
			, Min(measurement_date)
			, Max(measurement_date)
		FROM measurement
		GROUP BY person_id
	UNION
		SELECT person_id
			, Min(death_date)
			, Max(death_date)
		FROM death
		GROUP BY person_id
	) T
	GROUP BY t.PERSON_ID
) obs_dates
LEFT OUTER JOIN
-- end date -> date of last contact
(
	SELECT person_id
		, CAST(max(naaccr_item_value) as date) max_date
	FROM temp.naaccr_data_points_temp
	WHERE naaccr_item_number = '1750'
	AND naaccr_item_value IS NOT NULL
	AND LEN(naaccr_item_value) = '8'
	GROUP BY person_id
) ndp
ON obs_dates.person_id = ndp.person_id
;

-- Update existing obs period
-- take min and max values of existing obs period and the temp obs period created above
UPDATE observation_period
SET observation_period_start_date = obs.observation_period_start_date
	,observation_period_end_date = obs.observation_period_end_date
FROM
(
	SELECT
		person_id obs_person_id
		,MIN(observation_period_start_date) observation_period_start_date
		,MAX(observation_period_end_date) observation_period_end_date
	FROM
	(
    SELECT observation_period_id
        , person_id
        , observation_period_start_date
        , observation_period_end_date
        , period_type_concept_id
		FROM observation_period
		UNION
    SELECT observation_period_id
        , person_id
        , observation_period_start_date
        , observation_period_end_date
        , period_type_concept_id
		FROM temp.observation_period_temp
	) x
	GROUP BY x.person_id
) obs
WHERE person_id = obs.obs_person_id;

-- If new person, create new obs period
SET IDENTITY_INSERT observation_period ON;										  
INSERT INTO observation_period
        (	
		observation_period_id		
        ,person_id
        ,observation_period_start_date
        ,observation_period_end_date
        ,period_type_concept_id)
SELECT
	observation_period_id
	,person_id
	,MIN(observation_period_start_date) observation_period_start_date
	,MAX(observation_period_end_date) observation_period_end_date
	,44814724	-- TODO
FROM temp.observation_period_temp
WHERE person_id NOT IN (select person_id from observation_period)
GROUP BY observation_period_id, person_id;
SET IDENTITY_INSERT observation_period OFF;										   


INSERT INTO dbo.METADATA
SELECT *
FROM temp.METADATA_TEMP;


--Cleanup
--Delete temp tables
--IF OBJECT_ID('temp.naaccr_data_points_temp', 'U') IS NOT NULL           -- Drop temp table if it exists
--	  DROP TABLE temp.naaccr_data_points_temp;

--IF OBJECT_ID('temp.condition_occurrence_temp', 'U') IS NOT NULL           -- Drop temp table if it exists
--	DROP TABLE temp.condition_occurrence_temp;

--IF OBJECT_ID('temp.measurement_temp', 'U') IS NOT NULL           -- Drop temp table if it exists
--	DROP TABLE temp.measurement_temp;

--IF OBJECT_ID('temp.episode_temp', 'U') IS NOT NULL           -- Drop temp table if it exists
--	DROP TABLE temp.episode_temp;

--IF OBJECT_ID('temp.episode_event_temp', 'U') IS NOT NULL           -- Drop temp table if it exists
--	DROP TABLE temp.episode_event_temp;

--IF OBJECT_ID('temp.procedure_occurrence_temp', 'U') IS NOT NULL           -- Drop temp table if it exists
--	DROP TABLE temp.procedure_occurrence_temp;

--IF OBJECT_ID('temp.drug_exposure_temp', 'U') IS NOT NULL           -- Drop temp table if it exists
--	DROP TABLE temp.drug_exposure_temp;

--IF OBJECT_ID('temp.observation_temp', 'U') IS NOT NULL           -- Drop temp table if it exists
--	DROP TABLE temp.observation_temp;

--IF OBJECT_ID('temp.fact_relationship_temp', 'U') IS NOT NULL           -- Drop temp table if it exists
--	DROP TABLE temp.fact_relationship_temp;

--IF OBJECT_ID('temp.observation_period_temp', 'U') IS NOT NULL           -- Drop temp table if it exists
--	DROP TABLE temp.observation_period_temp;

--IF OBJECT_ID('temp.ambig_schema_discrim', 'U') IS NOT NULL           -- Drop temp table if it exists
--  DROP TABLE temp.ambig_schema_discrim;

--IF OBJECT_ID('temp.tmp_naaccr_data_points_temp_dates', 'U') IS NOT NULL           -- Drop temp table if it exists
--  DROP TABLE temp.tmp_naaccr_data_points_temp_dates;

--IF OBJECT_ID('temp.tmp_concept_naaccr_procedures', 'U') IS NOT NULL           -- Drop temp table if it exists
--  DROP TABLE temp.tmp_concept_naaccr_procedures;

--IF OBJECT_ID('temp.metadata_temp', 'U') IS NOT NULL           -- Drop temp table if it exists
--  DROP TABLE temp.metadata_temp;

COMMIT;
