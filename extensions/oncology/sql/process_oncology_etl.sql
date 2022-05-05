/* Scripts assumes:
	-input data exists on same database in specified format inside of 'naacr_data_points'
	-histology_site is represented in ICDO3 concept_code format
	-the 'person_id' column is already populated

Script downloaded from: https://github.com/OHDSI/OncologyWG/blob/master/etl/naaccr_etl_sqlserver.sql
*/

/****  DATA PREP  ****/
-- Initial data insert
INSERT INTO temp.naaccr_data_points_temp WITH (TABLOCK)
SELECT
	ndp.person_id,
	record_id,
	histology_site,
	naaccr_item_number,
	CASE
		WHEN LEN(naaccr_item_value) > 255 THEN SUBSTRING(naaccr_item_value, 1, 255)
		ELSE naaccr_item_value
	END,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL
FROM preload.naaccr_data_points ndp
-- only consider valid person_id
INNER JOIN person per
    ON ndp.person_id = per.person_id
    AND ndp.naaccr_item_value IS NOT NULL
    AND ndp.naaccr_item_value != ''
    AND ndp.naaccr_item_number NOT IN ('1810'--ADDR CURRENT--CITY
    );

/*
Fix values to match naaccr value set
*/
update temp.naaccr_data_points_temp
set naaccr_item_value = 0
where naaccr_item_value = 'Not a Paired Site'
and naaccr_item_number = 410

update temp.naaccr_data_points_temp
set naaccr_item_value = 1
where naaccr_item_value = 'Right: Origin of Primary'
and naaccr_item_number = 410

update temp.naaccr_data_points_temp
set naaccr_item_value = 2
where naaccr_item_value = 'Left: Origin of Primary'
and naaccr_item_number = 410

update temp.naaccr_data_points_temp
set naaccr_item_value = 3
where naaccr_item_value = 'Only One Side Involved Right or Left'
and naaccr_item_number = 410

update temp.naaccr_data_points_temp
set naaccr_item_value = 4
where naaccr_item_value like 'Bilateral Involvement - Origin Unknown for a Singl%'
and naaccr_item_number = 410

update temp.naaccr_data_points_temp
set naaccr_item_value = 5
where naaccr_item_value = 'Paired Site; Midline Tumor'
and naaccr_item_number = 410

update temp.naaccr_data_points_temp
set naaccr_item_value = 9
where naaccr_item_value = 'Paired Site No Information Concerning Laterality'
and naaccr_item_number = 410

update temp.naaccr_data_points_temp
set naaccr_item_value = 'pX'
where naaccr_item_value = 'p X'
and naaccr_item_number = 880

update temp.naaccr_data_points_temp
set naaccr_item_value = 'p1MI'
where naaccr_item_value = 'p1M'
and naaccr_item_number = 880

-- Set concept_code and concept_id to values in range 1-89
update temp.naaccr_data_points_temp
	set value_concept_code = '820@01-89', 
		value_concept_id = 35942326
where naaccr_item_value between '01' and '89' 
and naaccr_item_number = 820

update temp.naaccr_data_points_temp
	set value_concept_code = '830@01-89', 
		value_concept_id = 35942224
where naaccr_item_value between '01' and '89' 
and naaccr_item_number = 830


-- Format dates
-- TODO: Add 1750 to this list. Determine if other date fields also dont have relationships
-- Set invalid dates to NULL
--UPDATE temp.naaccr_data_points_temp
--SET naaccr_item_value =
--                       CASE
--                         WHEN LEN(
--                           REPLACE(naaccr_item_value, '/', '')
--                           ) != 8 THEN NULL
--                         WHEN ISNUMERIC(naaccr_item_value) <> 1 THEN NULL
--                         ELSE CASE
--                             WHEN CAST(
--                               SUBSTRING(naaccr_item_value, 1, 4) AS int
--                               ) NOT BETWEEN 1800
--                               AND 2099 THEN NULL
--                             WHEN CAST(
--                               SUBSTRING(naaccr_item_value, 5, 2) AS int
--                               ) NOT BETWEEN 1
--                               AND 12 THEN NULL
--                             WHEN CAST(
--                               SUBSTRING(naaccr_item_value, 7, 2) AS int
--                               ) NOT BETWEEN 1
--                               AND 31 THEN NULL
--                             ELSE naaccr_item_value
--                           END
--                       END
--WHERE naaccr_item_number IN (
---- todo: verify this list
--SELECT
--DISTINCT
--  c.concept_code
--FROM xref.concept c
--INNER JOIN xref.concept_relationship cr
--  ON cr.concept_id_1 = c.concept_id
--  AND cr.relationship_id IN ('Start date of', 'End date of')
--WHERE c.vocabulary_id = 'NAACCR');


-- Trim values just in case leading or trailing spaces
UPDATE temp.naaccr_data_points_temp
SET naaccr_item_value = LTRIM(RTRIM(naaccr_item_value));

-- Start with ambiguous schemas
UPDATE temp.naaccr_data_points_temp
SET schema_concept_id = schm.schema_concept_id,
    schema_concept_code = schm.schema_concept_code
FROM (SELECT DISTINCT
  person_id pid,
  asd.schema_concept_id,
  asd.schema_concept_code
FROM (SELECT DISTINCT
  person_id,
  histology_site,
  naaccr_item_number,
  naaccr_item_value
FROM temp.naaccr_data_points_temp
WHERE schema_concept_id IS NULL
--AND naaccr_item_number in (SELECT DISTINCT discrim_item_num FROM .ambig_schema_discrim)
AND naaccr_item_number IN ('220', '2879')) x
INNER JOIN (SELECT DISTINCT
  conc.concept_code,
  cr.concept_id_2
FROM xref.concept conc
INNER JOIN xref.concept_relationship cr
  ON conc.vocabulary_id = 'ICDO3'
  AND cr.concept_id_1 =
  conc.concept_id
  AND relationship_id = 'ICDO to Schema'
  -- Theres a ton of duplicated schemas here that arent in the mapping file... Item/value must be identical between schemas?
  AND cr.concept_id_2 IN (SELECT DISTINCT
    schema_concept_id
  FROM temp.ambig_schema_discrim)) ambig_cond
  ON x.histology_site = ambig_cond.concept_code
INNER JOIN temp.ambig_schema_discrim asd
  ON ambig_cond.concept_id_2 = asd.schema_concept_id
  AND x.naaccr_item_number = asd.discrim_item_num
  AND x.naaccr_item_value = asd.discrim_item_value) schm
WHERE person_id = schm.pid;


-- Append standard schemas - uses histology_site
UPDATE temp.naaccr_data_points_temp
SET schema_concept_id = schm.concept_id,
    schema_concept_code = schm.concept_code
FROM xref.concept c1
JOIN xref.concept_relationship cr1
  ON c1.concept_id = cr1.concept_id_1
  AND cr1.relationship_id = 'ICDO to Schema'
  AND c1.vocabulary_id = 'ICDO3'
JOIN xref.concept schm
  ON cr1.concept_id_2 = schm.concept_id
  AND schm.vocabulary_id = 'NAACCR'
WHERE temp.naaccr_data_points_temp.histology_site = c1.concept_code
AND temp.naaccr_data_points_temp.schema_concept_id IS NULL;


-- Variables
-- schema-independent
-- Variables
UPDATE temp.naaccr_data_points_temp
SET variable_concept_code = cv.variable_concept_code,
    variable_concept_id = cv.variable_concept_id
FROM (SELECT DISTINCT
  c1.concept_code AS concept_code,
  CASE
    WHEN COALESCE(c1.standard_concept, '') = 'S' THEN c1.concept_code
    ELSE c2.concept_code
  END AS variable_concept_code,
  CASE
    WHEN COALESCE(c1.standard_concept, '') = 'S' THEN c1.concept_id
    ELSE c2.concept_id
  END AS variable_concept_id
FROM xref.concept c1
LEFT JOIN xref.concept_relationship cr1
  ON c1.concept_id = cr1.concept_id_1
  AND cr1.relationship_id = 'Maps to'
LEFT JOIN xref.concept c2
  ON cr1.concept_id_2 = c2.concept_id
WHERE c1.vocabulary_id = 'NAACCR'
AND c1.concept_class_id = 'NAACCR Variable') cv
WHERE temp.naaccr_data_points_temp.variable_concept_id IS NULL
AND temp.naaccr_data_points_temp.naaccr_item_number = cv.concept_code;

--Fix value_concept_code from 756
update temp.naaccr_data_points_temp
	set value_concept_code = '756@002-988', 
		value_concept_id = 35942447
where naaccr_item_value between '002' and '988' 
and naaccr_item_number = 756

--Set variable_concept_code to 756
update temp.naaccr_data_points_temp
	set variable_concept_code = '756',
		variable_concept_id = 35918552
where naaccr_item_number = 756

-- schema dependent
UPDATE temp.naaccr_data_points_temp
SET variable_concept_code = c1.concept_code,
    variable_concept_id = c1.concept_id
FROM xref.concept c1
WHERE c1.vocabulary_id = 'NAACCR'
AND c1.concept_class_id = 'NAACCR Variable'
AND temp.naaccr_data_points_temp.variable_concept_id IS NULL
AND c1.concept_id IS NOT NULL
AND CONCAT(temp.naaccr_data_points_temp.schema_concept_code, '@', temp.naaccr_data_points_temp.naaccr_item_number) = c1.concept_code;


-- schema-independent
UPDATE temp.naaccr_data_points_temp
SET variable_concept_code = c1.concept_code,
    variable_concept_id = c1.concept_id
FROM xref.concept c1
WHERE c1.vocabulary_id = 'NAACCR'
AND c1.concept_class_id = 'NAACCR Variable'
AND temp.naaccr_data_points_temp.variable_concept_id IS NULL
AND c1.concept_id IS NOT NULL
AND c1.standard_concept IS NULL
AND temp.naaccr_data_points_temp.naaccr_item_number = c1.concept_code;


-- Values schema-independent
-- Make sure vocabulary tables are indexed
UPDATE temp.naaccr_data_points_temp
SET value_concept_code = c1.concept_code,
    value_concept_id = c1.concept_id
FROM xref.concept c1
WHERE temp.naaccr_data_points_temp.value_concept_id IS NULL
AND c1.concept_id IS NOT NULL
AND c1.vocabulary_id = 'NAACCR'
AND c1.concept_class_id = 'NAACCR Value'
AND CONCAT(temp.naaccr_data_points_temp.variable_concept_code, '@', temp.naaccr_data_points_temp.naaccr_item_value) = c1.concept_code
AND temp.naaccr_data_points_temp.naaccr_item_number NOT IN (-- todo: verify this list
SELECT DISTINCT
  c.concept_code
FROM xref.concept c
INNER JOIN xref.concept_relationship cr
  ON cr.concept_id_1 = c.concept_id
  AND cr.relationship_id IN ('Start date of', 'End date of')
WHERE c.vocabulary_id = 'NAACCR');


-- Values schema-independent (handle Observation domain values)
-- This is an expensive query, make sure vocabulary tables are indexed
UPDATE temp.naaccr_data_points_temp
SET value_concept_code = c1.concept_code,
    value_concept_id = c1.concept_id
FROM xref.concept c1
WHERE temp.naaccr_data_points_temp.value_concept_id IS NULL
AND c1.concept_id IS NOT NULL
AND c1.vocabulary_id = 'NAACCR'
AND c1.concept_class_id = 'NAACCR Value'
AND CONCAT(temp.naaccr_data_points_temp.naaccr_item_number, '@', temp.naaccr_data_points_temp.naaccr_item_value) = c1.concept_code
AND temp.naaccr_data_points_temp.naaccr_item_number NOT IN (-- todo: verify this list
SELECT DISTINCT
  c.concept_code
FROM xref.concept c
INNER JOIN xref.concept_relationship cr
  ON cr.concept_id_1 = c.concept_id
  AND cr.relationship_id IN ('Start date of', 'End date of')
WHERE c.vocabulary_id = 'NAACCR');


-- Values schema-dependent
UPDATE temp.naaccr_data_points_temp
SET   value_concept_code = c1.concept_code
    , value_concept_id   = c1.concept_id
FROM xref.concept c1
WHERE temp.naaccr_data_points_temp.value_concept_id IS NULL
AND c1.concept_id IS NOT NULL
AND c1.vocabulary_id = 'NAACCR'
AND c1.concept_class_id = 'NAACCR Value'
AND CONCAT(temp.naaccr_data_points_temp.schema_concept_code, '@', temp.naaccr_data_points_temp.variable_concept_code,'@', temp.naaccr_data_points_temp.naaccr_item_value) = c1.concept_code
AND temp.naaccr_data_points_temp.naaccr_item_number NOT IN(-- todo: verify this list
    SELECT DISTINCT c.concept_code
    FROM xref.concept c
    INNER JOIN xref.concept_relationship cr
    ON  cr.concept_id_1 = c.concept_id
    AND cr.relationship_id IN ('Start date of', 'End date of')
    WHERE c.vocabulary_id = 'NAACCR'
);

-- Type
UPDATE temp.naaccr_data_points_temp
SET type_concept_id = cr1.concept_id_2
FROM xref.concept_relationship cr1
WHERE cr1.relationship_id = 'Has type'
AND temp.naaccr_data_points_temp.variable_concept_id = cr1.concept_id_1;


-- Building indexes to optimize performance
CREATE INDEX idx_cr_ndpt_record_id            ON temp.naaccr_data_points_temp  (record_id);
CREATE INDEX idx_cr_ndpt_naaccr_item_number   ON temp.naaccr_data_points_temp  (naaccr_item_number);
CREATE INDEX idx_cr_ndpt_naaccr_item_value    ON temp.naaccr_data_points_temp  (naaccr_item_value);
CREATE INDEX idx_cr_ndpt_variable_concept_id  ON temp.naaccr_data_points_temp  (variable_concept_id);


-- DEATH
--INSERT INTO death (
--      person_id
--    , death_date
--    , death_datetime
--    , death_type_concept_id
--    , cause_concept_id
--    , cause_source_value
--    , cause_source_concept_id
--)
--SELECT
--	 person_id
--	,max_dth_date
--	,max_dth_date
--	,0 -- TODO
--	,0 -- TODO
--	,NULL
--	,0
--FROM
--(
--	SELECT distinct ndp.person_id
--		   ,CAST(MAX(ndp.naaccr_item_value) as date) max_dth_date
--	FROM preload.naaccr_data_points ndp
--	INNER JOIN preload.naaccr_data_points ndp2
--		--ON ndp.naaccr_item_number = '1750'		-- date of last contact
--		ON ndp2.naaccr_item_number = '1760'	-- vital status
--		AND ndp.naaccr_item_value IS NOT NULL
--		AND len(ndp.naaccr_item_value) = 10
--		AND ndp2.naaccr_item_value = 'dead' --'0'='Dead'
--		AND ndp.record_id = ndp2.record_id
--		AND ndp.person_id IS NOT NULL
--	GROUP BY ndp.person_id
--) x
--INNER JOIN preload.naaccr_data_points y
--ON 	x.person_id = y.person_id
--AND y.naaccr_item_number = '1910'

--WHERE x.person_id NOT IN (SELECT person_id from DEATH)
--;


/***** DIAGNOSIS *****/

-- Condition Occurrence
INSERT INTO temp.condition_occurrence_temp with (tablock) (
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
	, record_id
)
SELECT COALESCE( (SELECT MAX(condition_occurrence_id) FROM temp.condition_occurrence_temp)
	, (SELECT MAX(condition_occurrence_id) FROM condition_occurrence)
	, 0) + row_number() over (order by s.person_id) AS condition_occurrence_id
    , s.person_id AS person_id
    , isnull(c2.concept_id,0) AS condition_concept_id
    , CAST(s.naaccr_item_value as date) AS condition_start_date
    , CAST(s.naaccr_item_value as date) AS condition_start_datetime
    , NULL AS condition_end_date
    , NULL AS condition_end_datetime
    , 32534 AS condition_type_concept_id -- �Tumor registry� concept
    , NULL AS stop_reason
    , NULL AS provider_id
    , NULL AS visit_occurrence_id
--    , NULL AS visit_detail_id
    , s.histology_site AS condition_source_value
    , isnull(d.concept_id,0) AS condition_source_concept_id
    , NULL AS condition_status_source_value
    , 0 AS condition_status_concept_id
    , s.record_id AS record_id
FROM (
    SELECT person_id
        , record_id
        , histology_site
        , naaccr_item_number
        , naaccr_item_value
        , schema_concept_id
        , schema_concept_code
        , variable_concept_id
        , variable_concept_code
        , value_concept_id
        , value_concept_code
        , type_concept_id
    FROM temp.naaccr_data_points_temp
    WHERE naaccr_item_number = '390'  -- Date of diag
    AND naaccr_item_value IS NOT NULL
    AND person_id IS NOT NULL
) s
    JOIN xref.concept d
    ON d.vocabulary_id = 'ICDO3'
    AND d.concept_code = s.histology_site
    JOIN xref.concept_relationship ra
    ON ra.concept_id_1 = d.concept_id
    AND ra.relationship_id = 'Maps to'
    JOIN xref.concept  c2
    ON c2.standard_concept = 'S'
    AND ra.concept_id_2 = c2.concept_id
    AND c2.domain_id = 'Condition'
;


-- condition modifiers
DECLARE @MaxId INT
SET @MaxId = (SELECT MAX(measurement_id) FROM measurement)

INSERT INTO temp.measurement_temp with (tablock)
(
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
    , record_id
)
SELECT COALESCE(@MaxId, 0) + row_number() over (order by ndp.person_id) AS measurement_id
    , ndp.person_id AS person_id
    , isnull(conc.concept_id,0) AS measurement_concept_id
    , cot.condition_start_date AS measurement_date
    , NULL AS measurement_time
    , cot.condition_start_datetime AS measurement_datetime
    , 32534 AS measurement_type_concept_id -- �Tumor registry� concept
    , conc_num.operator_concept_id AS operator_concept_id
    , CASE
		WHEN ndp.type_concept_id = 32676 --'Numeric'
			THEN TRY_CAST(ndp.naaccr_item_value AS NUMERIC)
		ELSE 
			NULL
	  END as value_as_number
    , ndp.value_concept_id AS value_as_concept_id
    , COALESCE(unit_cr.concept_id_2, conc_num.unit_concept_id) AS unit_concept_id
    , NULL AS range_low
    , NULL AS range_high
    , NULL AS provider_id
    , NULL AS visit_occurrence_id
    , NULL AS visit_detail_id
    , ndp.variable_concept_code AS measurement_source_value
    , ndp.variable_concept_id AS measurement_source_concept_id
    , NULL AS unit_source_value
    , left(naaccr_item_value, 50) AS value_source_value
    , cot.condition_occurrence_id AS modifier_of_event_id
    , 1147127 AS modifier_field_concept_id -- condition_occurrence.condition_occurrence_id concept
    , ndp.record_id AS record_id
FROM
(
    SELECT person_id
        	, record_id
        	, histology_site
        	, naaccr_item_number
        	, naaccr_item_value
        	, schema_concept_id
        	, schema_concept_code
        	, variable_concept_id
        	, variable_concept_code
        	, value_concept_id
        	, value_concept_code
        	, type_concept_id
    FROM temp.naaccr_data_points_temp
    -- concept is modifier of a diagnosis item (child of site/hist)
    WHERE variable_concept_id IN (  
		SELECT DISTINCT concept_id_1
        FROM xref.concept_relationship
        WHERE relationship_id = 'Has parent item'
        AND concept_id_2 in (35918588 -- primary site
							,35918916) -- histology
     )
    -- filter empty values
    AND LEN(naaccr_item_value) > 0

	--Force item 756 into table
	UNION 
	SELECT person_id
        	, record_id
        	, histology_site
        	, naaccr_item_number
        	, naaccr_item_value
        	, schema_concept_id
        	, schema_concept_code
        	, variable_concept_id
        	, variable_concept_code
        	, value_concept_id
        	, value_concept_code
        	, type_concept_id
	FROM temp.naaccr_data_points_temp
	WHERE naaccr_item_number = 756
) ndp
-- Get condition_occurrence record
INNER JOIN temp.condition_occurrence_temp cot
ON ndp.person_id = cot.person_id
-- Get standard concept
INNER JOIN xref.concept_relationship cr
on ndp.variable_concept_id = cr.concept_id_1
and cr.relationship_id = 'Maps to'
INNER JOIN xref.concept conc
on cr.concept_id_2 = conc.concept_id
AND conc.domain_id = 'Measurement'
-- Get Unit
LEFT OUTER JOIN xref.concept_relationship unit_cr
ON ndp.variable_concept_id = unit_cr.concept_id_1
and unit_cr.relationship_id = 'Has unit'
-- Get numeric value
LEFT OUTER JOIN xref.concept_numeric conc_num
ON ndp.type_concept_id = 32676 --'Numeric'
AND ndp.value_concept_id = conc_num.concept_id
;


-- Diagnosis episodes
INSERT INTO temp.episode_temp with (tablock)
(
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
	, record_id
)
SELECT COALESCE((SELECT MAX(episode_id) FROM episode), 0) + row_number() over(order by person_id) AS episode_id
    , cot.person_id AS person_id
    , 32528 AS episode_concept_id  --Disease First Occurrence
    , cot.condition_start_datetime AS episode_start_datetime        --?
    , NULL AS episode_end_datetime          --?
    , NULL AS episode_parent_id
    , NULL AS episode_number
    , cot.condition_concept_id AS episode_object_concept_id
    , 32546 AS episode_type_concept_id --Episode derived from registry
    , cot.condition_source_value AS episode_source_value
    , cot.condition_source_concept_id AS episode_source_concept_id
    , cot.record_id AS record_id
FROM temp.condition_occurrence_temp cot;


INSERT INTO temp.episode_event_temp
(
	episode_id
	,event_id
	,episode_event_field_concept_id
)
SELECT et.episode_id AS episode_id
    , cot.condition_occurrence_id AS event_id
    , 1147127 AS episode_event_field_concept_id --condition_occurrence.condition_occurrence_id
FROM temp.condition_occurrence_temp cot
JOIN temp.episode_temp et
ON cot.person_id = et.person_id
;


--Step 7: Copy Condition Occurrence Measurements for Disease Episode
INSERT INTO temp.measurement_temp with (tablock)
(
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
	, record_id
)
SELECT COALESCE( (SELECT MAX(measurement_id) FROM temp.measurement_temp)
 , (SELECT MAX(measurement_id) FROM measurement)
 , 0) + row_number() over(order by measurement_id) AS measurement_id
    , mt.person_id AS person_id
    , mt.measurement_concept_id AS measurement_concept_id
    , mt.measurement_date AS measurement_date
    , mt.measurement_time AS measurement_time
    , mt.measurement_datetime AS measurement_datetime
    , mt.measurement_type_concept_id AS measurement_type_concept_id
    , mt.operator_concept_id AS operator_concept_id
    , mt.value_as_number AS value_as_number
    , mt.value_as_concept_id AS value_as_concept_id
    , mt.unit_concept_id AS unit_concept_id
    , mt.range_low AS range_low
    , mt.range_high AS range_high
    , mt.provider_id AS provider_id
    , mt.visit_occurrence_id AS visit_occurrence_id
    , mt.visit_detail_id AS visit_detail_id
    , mt.measurement_source_value AS measurement_source_value
    , mt.measurement_source_concept_id AS measurement_source_concept_id
    , mt.unit_source_value AS unit_source_value
    , mt.value_source_value AS value_source_value
    , et.episode_id AS modifier_of_event_id
    , 1000000003 AS modifier_field_concept_id -- �episode.episode_id� concept
    , mt.record_id AS record_id
FROM temp.measurement_temp mt
JOIN temp.episode_temp et
ON mt.record_id = et.record_id
;


-- Treatment Episodes
-- Temp table with NAACCR dates
-- Used in joins instead full naaccr_data_points table to improve performance

INSERT INTO temp.tmp_naaccr_data_points_temp_dates with (tablock)
SELECT *
FROM temp.naaccr_data_points_temp src
WHERE EXISTS
(
    SELECT 1
    FROM xref.concept_relationship cr
    WHERE cr.concept_id_1 = src.variable_concept_id
    AND cr.relationship_id IN ('End date of', 'Start date of')
);

CREATE INDEX idx_ndptmp_date_join ON temp.tmp_naaccr_data_points_temp_dates (variable_concept_id, person_id);


-- populate episode_temp

-- insert drugs INTO temp.episode_temp
INSERT INTO temp.episode_temp with (tablock)
(
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
	, record_id
)
SELECT COALESCE( (SELECT MAX(episode_id) FROM temp.episode_temp)
 , (SELECT MAX(episode_id) FROM episode)
 , 0) + row_number() over(order by ndp.person_id) AS episode_id
    , ndp.person_id AS person_id
    , ndp.variable_concept_id  -- 32531 Treatment regimen
    , CAST(ndp_dates.naaccr_item_value as date) AS episode_start_datetime        --?
    , NULL AS episode_end_datetime          --?
    , NULL AS episode_parent_id
    , NULL AS episode_number
    , c2.concept_id AS episode_object_concept_id
    , 32546 AS episode_type_concept_id --Episode derived from registry
    , c2.concept_code AS episode_source_value
    , c2.concept_id AS episode_source_concept_id
    , ndp.record_id AS record_id
FROM
(
SELECT person_id
      	, record_id
      	, histology_site
      	, naaccr_item_number
      	, naaccr_item_value
      	, schema_concept_id
      	, schema_concept_code
      	, variable_concept_id
      	, variable_concept_code
      	, value_concept_id
      	, value_concept_code
      	, type_concept_id
FROM temp.naaccr_data_points_temp
WHERE naaccr_item_number IN ( '1390', '1400', '1410')
) ndp
--Get value
INNER JOIN xref.concept c1 ON c1.concept_class_id = 'NAACCR Variable' AND ndp.naaccr_item_number = c1.concept_code
INNER JOIN xref.concept_relationship cr1 ON c1.concept_id = cr1.concept_id_1 AND cr1.relationship_id = 'Has Answer'
INNER JOIN xref.concept c2 ON cr1.concept_id_2 = c2.concept_id AND CONCAT(c1.concept_code,'@', ndp.naaccr_item_value) = c2.concept_code
-- Get start date
INNER JOIN xref.concept_relationship cr2 ON c1.concept_id = cr2.concept_id_1
AND cr2.relationship_id = 'Has start date'
INNER JOIN temp.tmp_naaccr_data_points_temp_dates ndp_dates
ON cr2.concept_id_2 = ndp_dates.variable_concept_id
AND ndp.person_id = ndp_dates.person_id
-- filter null dates
AND ndp_dates.naaccr_item_value IS NOT NULL;


-- Temp table with concept_ids only to optimize insert query
INSERT INTO temp.tmp_concept_naaccr_procedures
SELECT
c1.concept_id     AS c1_concept_id,
c1.concept_code   AS c1_concept_code,
c2.concept_id     AS c2_concept_id,
c2.concept_code   AS c2_concept_code
FROM xref.concept c1
INNER JOIN xref.concept_relationship cr1
ON  c1.concept_id = cr1.concept_id_1
AND cr1.relationship_id = 'Has Answer'
INNER JOIN xref.concept c2
ON  cr1.concept_id_2 = c2.concept_id
AND c2.domain_id = 'Procedure'
WHERE c1.vocabulary_id = 'NAACCR'
AND c1.concept_class_id = 'NAACCR Variable'
;


-- insert procedure (all except surgeries)
INSERT INTO temp.episode_temp with (tablock)
(
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
	, record_id
)
SELECT COALESCE( (SELECT MAX(episode_id) FROM temp.episode_temp)
 , (SELECT MAX(episode_id) FROM episode)
 , 0) + row_number() over(order by ndp.person_id) AS episode_id
    , ndp.person_id AS person_id
    , ndp.variable_concept_id  -- 32531 Treatment regimen
    , CAST(ndp_dates.naaccr_item_value as date) AS episode_start_datetime        --?
    -- Placeholder... TODO:better universal solution for isnull?
	, CASE WHEN LEN(end_dates.naaccr_item_value) > 1
			THEN CAST(end_dates.naaccr_item_value as date)
			ELSE NULL 
			END AS episode_end_datetime 
    , NULL AS episode_parent_id
    , NULL AS episode_number
    , c.c2_concept_id AS episode_object_concept_id
    , 32546 AS episode_type_concept_id --Episode derived from registry
    , c.c2_concept_code AS episode_source_value
    , c.c2_concept_id 
    , ndp.record_id AS record_id
FROM
(
	SELECT person_id
      		, record_id
      		, histology_site
      		, naaccr_item_number
      		, naaccr_item_value
      		, schema_concept_id
      		, schema_concept_code
      		, variable_concept_id
      		, variable_concept_code
      		, value_concept_id
      		, value_concept_code
      		, type_concept_id
	FROM temp.naaccr_data_points_temp
	WHERE naaccr_item_number NOT IN ( '1290' )
) ndp
INNER JOIN temp.tmp_concept_naaccr_procedures c
ON CONCAT(c.c1_concept_code,'@', ndp.naaccr_item_value) = c.c2_concept_code
AND ndp.naaccr_item_number = c.c1_concept_code
INNER JOIN xref.concept_relationship cr2
ON c.c1_concept_id = cr2.concept_id_1
AND cr2.relationship_id = 'Has start date'
INNER JOIN temp.tmp_naaccr_data_points_temp_dates ndp_dates
ON cr2.concept_id_2 = ndp_dates.variable_concept_id
-- filter null dates
AND ndp_dates.naaccr_item_value IS NOT NULL
AND ndp.record_id = ndp_dates.record_id
-- Get end date
LEFT OUTER JOIN xref.concept_relationship cr3
ON c.c1_concept_id = cr3.concept_id_1
AND cr3.relationship_id = 'Has end date'
LEFT OUTER JOIN temp.tmp_naaccr_data_points_temp_dates end_dates
ON cr3.concept_id_2 = end_dates.variable_concept_id
--ON end_dates.naaccr_item_number = '3220'
-- filter null dates
AND end_dates.naaccr_item_value IS NOT NULL
AND ndp.person_id = end_dates.person_id
;


-- insert surgery procedures
-- this requires its own schema mapping (ICDO to Proc Schema)
INSERT INTO temp.episode_temp (
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
	, record_id
)
SELECT COALESCE( (SELECT MAX(episode_id) FROM temp.episode_temp)
 , (SELECT MAX(episode_id) FROM episode)
 , 0) + row_number() over(order by ndp.person_id) AS episode_id
    , ndp.person_id AS person_id
    , 32531 -- Treatment regimen
    , CAST(ndp_dates.naaccr_item_value as date) AS episode_start_datetime        --?
    , NULL AS episode_end_datetime          --?
    , NULL AS episode_parent_id
    , NULL AS episode_number
    , var_conc.concept_id AS episode_object_concept_id
    , 32546 AS episode_type_concept_id --Episode derived from registry
    , var_conc.concept_code AS episode_source_value
    , var_conc.concept_id AS episode_source_concept_id
    , ndp.record_id AS record_id
FROM (
	SELECT person_id
      		, record_id
      		, histology_site
      		, naaccr_item_number
      		, naaccr_item_value
      		, schema_concept_id
      		, schema_concept_code
      		, variable_concept_id
      		, variable_concept_code
      		, value_concept_id
      		, value_concept_code
      		, type_concept_id
	FROM temp.naaccr_data_points_temp
	WHERE naaccr_item_number = '1290'
) ndp
-- get icdo
INNER JOIN xref.concept conc
ON vocabulary_id = 'ICDO3'
AND ndp.histology_site = conc.concept_code
-- get proc schema
INNER JOIN xref.concept_relationship cr_schema
ON conc.concept_id = cr_schema.concept_id_1
AND cr_schema.relationship_id = 'ICDO to Proc Schema'
INNER JOIN xref.concept schem_conc
ON cr_schema.concept_id_2 = schem_conc.concept_id
-- get procedure
INNER JOIN xref.concept var_conc
ON var_conc.concept_class_id = 'NAACCR Procedure'
AND CONCAT(schem_conc.concept_code, '@', 1290, '@', ndp.naaccr_item_value) = var_conc.concept_code
-- hardcoded for now until update
INNER JOIN temp.tmp_naaccr_data_points_temp_dates ndp_dates
ON ndp_dates.naaccr_item_number = '1200'
AND ndp.person_id = ndp_dates.person_id
-- filter null dates
WHERE ndp_dates.naaccr_item_value IS NOT NULL
;


-- Insert from episode_temp INTO temp.domain temp tables
-- drug
INSERT INTO temp.drug_exposure_temp (
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
	, record_id
)
SELECT COALESCE( (SELECT MAX(drug_exposure_id) FROM temp.drug_exposure_temp)
 , (SELECT MAX(drug_exposure_id) FROM drug_exposure)
 , 0) + row_number() over(order by et.person_id) AS drug_exposure_id
	, et.person_id AS person_id
	, et.episode_object_concept_id AS drug_concept_id
	, et.episode_start_datetime AS drug_exposure_start_date
	, et.episode_start_datetime AS drug_exposure_start_datetime
	, et.episode_start_datetime AS drug_exposure_end_date
	, et.episode_start_datetime AS drug_exposure_end_datetime
	, NULL AS verbatim_end_date
	, 32534 AS drug_type_concept_id -- �Tumor registry� concept. Fix me.
	, NULL AS stop_reason
	, NULL AS refills
	, NULL AS quantity
	, NULL AS days_supply
	, NULL AS sig
	, NULL AS route_concept_id
	, NULL AS lot_number
	, NULL AS provider_id
	, NULL AS visit_occurrence_id
	, NULL AS visit_detail_id
	, et.episode_source_value AS drug_source_value
	, et.episode_source_concept_id AS drug_source_concept_id
	, NULL AS route_source_value
	, NULL AS dose_unit_source_value
	, et.record_id 
FROM temp.episode_temp et
JOIN xref.concept c1
ON et.episode_object_concept_id = c1.concept_id
AND c1.standard_concept IS NULL
AND c1.domain_id = 'Drug';


-- procedure
INSERT INTO temp.procedure_occurrence_temp (
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
	, episode_id
	, record_id
)
SELECT COALESCE( (SELECT MAX(procedure_occurrence_id) FROM temp.procedure_occurrence_temp)
 , (SELECT MAX(procedure_occurrence_id) FROM procedure_occurrence)
 , 0) + row_number() over(order by et.person_id)  AS procedure_occurrence_id 
	, et.person_id AS person_id
	, et.episode_object_concept_id AS procedure_concept_id
	, et.episode_start_datetime AS procedure_date
	, et.episode_start_datetime AS procedure_datetime
	, 32534 AS procedure_type_concept_id -- �Tumor registry� concept. Fix me.
	, NULL AS modifier_concept_id
	, 1 AS quantity --Is this OK to hardcode?
	, NULL AS provider_id
	, NULL AS visit_occurrence_id
	, NULL AS visit_detail_id
	, et.episode_source_value AS procedure_source_value
	, et.episode_source_concept_id AS procedure_source_concept_id
	, NULL AS modifier_source_value
	, et.episode_id AS episode_id
	, et.record_id AS record_id
-- , c1.concept_name
FROM temp.episode_temp et
JOIN xref.concept c1
ON et.episode_object_concept_id = c1.concept_id
  AND c1.standard_concept = 'S'
  AND c1.domain_id = 'Procedure';


-- Update episode_event_temp

-- Connect Drug Exposure to Treatment Episodes in Episode Event
INSERT INTO temp.episode_event_temp (episode_id
, event_id
, episode_event_field_concept_id)
  SELECT
    et.episode_id AS episode_id,
    det.drug_exposure_id AS event_id,
    1147094 AS episode_event_field_concept_id --drug_exposure.drug_exposure_id
  FROM temp.drug_exposure_temp det
  JOIN temp.episode_temp et
    ON det.person_id = et.person_id
    AND det.drug_concept_id = et.episode_object_concept_id;


--Connect Procedure Occurrence to Treatment Episodes in Episode Event
INSERT INTO temp.episode_event_temp (
	 episode_id
	,event_id
	,episode_event_field_concept_id
)
SELECT
	et.episode_id AS episode_id,
	pet.procedure_occurrence_id AS event_id,
	1147082 AS episode_event_field_concept_id --procedure_occurrence.procedure_occurrence_id
FROM temp.procedure_occurrence_temp pet
 JOIN temp.episode_temp et
 ON pet.person_id = et.person_id
 AND pet.procedure_concept_id = et.episode_object_concept_id;


-- Drug Treatment Episodes:   Update to standard 'Regimen' concepts.
UPDATE temp.episode_temp
SET episode_object_concept_id = (
		CASE
			WHEN episode_source_value = '1390@01' THEN 35803401 --Hemonc Chemotherapy Modality
            WHEN episode_source_value = '1390@02' THEN 35803401
            WHEN episode_source_value = '1390@03' THEN 35803401
            WHEN episode_source_value = '1400@01' THEN 35803407
            WHEN episode_source_value = '1410@01' THEN 35803410
            ELSE episode_object_concept_id
        END
);


-- Treatment Episode Modifiers
CREATE INDEX idx_tmp_ep_record_id ON temp.episode_temp (record_id);

INSERT INTO temp.measurement_temp with (tablock)
(
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
	, record_id
)
SELECT COALESCE( (SELECT MAX(measurement_id) FROM temp.measurement_temp)
            , (SELECT MAX(measurement_id) FROM measurement)
            , 0) + row_number() over(order by ndp.person_id) AS measurement_id
	, ndp.person_id AS person_id
	, conc.concept_id AS measurement_concept_id
	, et.episode_start_datetime AS measurement_time
	, NULL
	, et.episode_start_datetime
	, 32534 AS measurement_type_concept_id -- �Tumor registry� concept
	, conc_num.operator_concept_id AS operator_concept_id
	, CASE
			WHEN ndp.type_concept_id = 32676 --'Numeric'
				THEN
					CASE
					WHEN ndp.value_concept_id IS NULL AND ISNUMERIC(ndp.naaccr_item_value) = 1
					THEN
						CAST(ndp.naaccr_item_value AS NUMERIC)
					ELSE
						COALESCE(conc_num.value_as_number, NULL)
					END
				ELSE
				NULL
			END as value_as_number
	, ndp.value_concept_id AS value_as_concept_id
	, COALESCE(unit_cr.concept_id_2, conc_num.unit_concept_id) AS unit_concept_id
	, NULL AS range_low
	, NULL AS range_high
	, NULL AS provider_id
	, NULL AS visit_occurrence_id
	, NULL AS visit_detail_id
	, ndp.variable_concept_code AS measurement_source_value
	, ndp.variable_concept_id AS measurement_source_concept_id
	, NULL AS unit_source_value
	, naaccr_item_value AS value_source_value
	, et.episode_id AS modifier_of_event_id
	, 1000000003 -- TODO: Need vocab update AS modifier_field_concept_id -- �episode.episode_id� concept
	, ndp.record_id AS record_id
FROM
(
	SELECT person_id
			, record_id
			, histology_site
			, naaccr_item_number
			, naaccr_item_value
			, schema_concept_id
			, schema_concept_code
			, variable_concept_id
			, variable_concept_code
			, value_concept_id
			, value_concept_code
			, type_concept_id
	FROM temp.naaccr_data_points_temp
	WHERE person_id IS NOT NULL
	AND LEN(naaccr_item_value) > 0
) ndp
INNER JOIN xref.concept_relationship cr1 
ON ndp.variable_concept_id = cr1.concept_id_1 
  AND cr1.relationship_id = 'Has parent item' 
  AND cr1.concept_id_2 in (
	 35918686  --Phase I Radiation Treatment Modality
	,35918378  --Phase II Radiation Treatment Modality
	,35918255  --Phase III Radiation Treatment Modality
	,35918593  --RX Summ--Surg Prim Site
)
-- Get episode_temp record
INNER JOIN temp.episode_temp et
ON ndp.person_id = et.person_id
-- restrict to treatment episodes
  AND et.episode_concept_id = 32531
INNER JOIN xref.concept_relationship cr2 
ON et.episode_source_concept_id = cr2.concept_id_1 
  AND cr2.relationship_id = 'Answer of' 
  AND cr1.concept_id_2 = cr2.concept_id_2
-- Get standard concept
INNER JOIN xref.concept_relationship cr
on ndp.variable_concept_id = cr.concept_id_1
  and cr.relationship_id = 'Maps to'
INNER JOIN xref.concept conc
on cr.concept_id_2 = conc.concept_id
  AND conc.domain_id = 'Measurement'
-- Get Unit
LEFT OUTER JOIN xref.concept_relationship unit_cr
ON ndp.variable_concept_id = unit_cr.concept_id_1
  and unit_cr.relationship_id = 'Has unit'
-- Get numeric value
LEFT OUTER JOIN xref.concept_numeric conc_num
ON ndp.type_concept_id = 32676 --'Numeric'
  AND ndp.value_concept_id = conc_num.concept_id ;


--Step 15: Copy Episode Measurements to Procedure Occurrence for Treatment Episodes
INSERT INTO temp.measurement_temp
(
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
	, record_id
)
SELECT COALESCE((SELECT MAX(measurement_id) FROM temp.measurement_temp)
 ,(SELECT MAX(measurement_id) FROM measurement)
 ,0) + row_number() over(order by mt.person_id) AS measurement_id
	    , mt.person_id AS person_id
	    , mt.measurement_concept_id AS measurement_concept_id
	    , mt.measurement_date AS measurement_date
	    , mt.measurement_time AS measurement_time
	    , mt.measurement_datetime AS measurement_datetime
	    , mt.measurement_type_concept_id AS measurement_type_concept_id
	    , mt.operator_concept_id AS operator_concept_id
	    , mt.value_as_number AS value_as_number
	    , mt.value_as_concept_id AS value_as_concept_id
	    , mt.unit_concept_id AS unit_concept_id
	    , mt.range_low AS range_low
	    , mt.range_high AS range_high
	    , mt.provider_id AS provider_id
	    , mt.visit_occurrence_id AS visit_occurrence_id
	    , mt.visit_detail_id AS visit_detail_id
	    , mt.measurement_source_value AS measurement_source_value
	    , mt.measurement_source_concept_id AS measurement_source_concept_id
	    , mt.unit_source_value AS unit_source_value
	    , mt.value_source_value AS value_source_value
	    , pet.procedure_occurrence_id AS modifier_of_event_id
	    , 1147084 AS modifier_field_concept_id -- �procedure_occurrence.procedure_concept_id� concept
	    , mt.record_id AS record_id
FROM temp.measurement_temp mt
JOIN temp.episode_temp et
ON mt.person_id = et.person_id
  AND et.episode_concept_id = 32531 --Treatment Regimen
  AND mt.modifier_of_event_id = et.episode_id
  AND mt.modifier_of_field_concept_id = 1000000003
JOIN temp.procedure_occurrence_temp pet
ON et.person_id = pet.person_id
  AND et.episode_object_concept_id = pet.procedure_concept_id;


--Step 16: Connect 'Treatment Episodes' to 'Disease Episodes' via parent_id
UPDATE temp.episode_temp
SET episode_parent_id = det.episode_id
FROM
(
	SELECT DISTINCT person_id pid, episode_id
	FROM temp.episode_temp
	WHERE episode_concept_id = 32528 --Disease First Occurrence
) det
WHERE person_id= det.pid
AND episode_concept_id = 32531; --Treatment Regimen


--Step 17: Observation
INSERT INTO temp.observation_temp
(
	observation_id
	, person_id
	, observation_concept_id
	, observation_date
	, observation_datetime
	, observation_type_concept_id
	, value_as_number
	, value_as_string
	, value_as_concept_id
	, unit_concept_id
	, qualifier_concept_id
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
	, record_id
)
SELECT COALESCE( (SELECT MAX(observation_id) FROM temp.observation_temp)
 ,(SELECT MAX(observation_id) FROM observation)
 ,0) + row_number() over(order by ndp.person_id) AS observation_id
    , ndp.person_id AS person_id
    , c1.concept_id AS observation_concept_id
    , CAST(ndp1.naaccr_item_value as date) AS observation_date
    , CAST(ndp1.naaccr_item_value as date) AS observation_datetime
    , 32534 AS observation_type_concept_id
    , NULL AS value_as_number
    , NULL AS value_as_concept_id
  	, NULL AS value_as_string
    , NULL AS unit_concept_id
  	, NULL AS qualifier_concept_id
    , NULL AS provider_id
    , NULL AS visit_occurrence_id
    , NULL AS visit_detail_id
    , ndp.value_concept_code AS observation_source_value
    , ndp.value_concept_id AS observation_source_concept_id
    , NULL AS unit_source_value
    , NULL AS qualifier_source_value
	--    , NULL AS observation_event_id
	--    , NULL AS obs_event_field_concept_id
	--	  , NULL AS value_as_datetime
    , ndp.record_id AS record_id
FROM temp.naaccr_data_points_temp AS ndp
INNER JOIN xref.concept_relationship cr1
ON ndp.value_concept_id = cr1.concept_id_1
    AND cr1.relationship_id = 'Maps to'
INNER JOIN xref.concept AS c1
ON cr1.concept_id_2 = c1.concept_id
	AND c1.vocabulary_id = 'NAACCR'
	AND c1.concept_class_id = 'NAACCR Value'
	AND c1.domain_id = 'Observation'
	AND c1.standard_concept = 'S'
INNER JOIN temp.naaccr_data_points_temp ndp1
ON ndp.person_id = ndp1.person_id
	AND ndp1.naaccr_item_number = '390'
INNER JOIN temp.episode_temp ep
ON ndp.person_id = ep.person_id
	-- disease first occurrence
	AND ep.episode_concept_id = 32528;


--Add remaining observation items
DECLARE @ObsMaxRowId INT
DECLARE @TempMaxRowId INT 

SET @ObsMaxRowId = (SELECT MAX(observation_id) FROM observation)
SET @TempMaxRowId = (SELECT MAX(observation_id) FROM temp.observation_temp)

;WITH item390 AS
  (SELECT person_id ,
          naaccr_item_value
   FROM temp.naaccr_data_points_temp
   WHERE naaccr_item_number = '390' -- Date of diag
     AND naaccr_item_value IS NOT NULL
     AND person_id IS NOT NULL ),
     itemsObs AS
  (SELECT person_id ,
          record_id ,
          histology_site ,
          naaccr_item_number ,
          naaccr_item_value ,
          schema_concept_id ,
          schema_concept_code ,
          variable_concept_id ,
          variable_concept_code ,
          value_concept_id ,
          value_concept_code ,
          type_concept_id
   FROM temp.naaccr_data_points_temp
   WHERE naaccr_item_number not in 
   (SELECT DISTINCT c.concept_code
    FROM xref.concept c
    INNER JOIN xref.concept_relationship cr
    ON  cr.concept_id_1 = c.concept_id
    AND cr.relationship_id IN ('Start date of', 'End date of')
    WHERE c.vocabulary_id = 'NAACCR'
	) --'390' -- Date of diag
     AND naaccr_item_value IS NOT NULL
     AND person_id IS NOT NULL )
INSERT INTO temp.observation_temp
(
	observation_id
	, person_id
	, observation_concept_id
	, observation_date
	, observation_datetime
	, observation_type_concept_id
	, value_as_number
	, value_as_string
	, value_as_concept_id
	, unit_concept_id
	, qualifier_concept_id
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
	, record_id
)
SELECT COALESCE(@TempMaxRowId, @ObsMaxRowId, 0) + row_number() over(ORDER BY a.person_id) AS observation_id ,
       b.person_id AS person_id ,
       ISNULL(d.concept_id_2, 0) AS observation_concept_id,
       CAST(a.naaccr_item_value AS date) AS observation_date,
       CAST(a.naaccr_item_value AS datetime) AS observation_datetime,
       32534 AS observation_type_concept_id,
	   NULL value_as_number,
	   value_as_string = b.naaccr_item_value,
       ISNULL(b.value_concept_id, c.concept_id) AS value_as_concept_id, 
       COALESCE(unit_cr.concept_id_2, conc_num.unit_concept_id) AS unit_concept_id ,
       NULL AS qualifier_concept_id,
       NULL AS provider_id,
       NULL AS visit_occurrence_id,
       NULL AS visit_detail_id,
       b.variable_concept_code AS observation_source_value,
       ISNULL(b.variable_concept_id, 0) AS observation_source_concept_id,
       NULL AS unit_source_value,
       NULL AS qualifier_source_value,
	    -- , NULL AS observation_event_id
		-- , NULL AS obs_event_field_concept_id
		-- , NULL AS value_as_datetime
       b.record_id AS record_id
FROM item390 a
JOIN itemsObs b ON a.person_id = b.person_id
JOIN xref.concept c ON c.vocabulary_id = 'NAACCR'
AND c.domain_id = 'Observation'
AND c.concept_code = b.naaccr_item_number
LEFT OUTER JOIN xref.concept_numeric conc_num
ON b.type_concept_id = 32676 --'Numeric'
AND b.value_concept_id = conc_num.concept_id
LEFT OUTER JOIN xref.concept_relationship unit_cr
ON b.variable_concept_id = unit_cr.concept_id_1
and unit_cr.relationship_id = 'Has unit'
LEFT OUTER JOIN xref.concept_relationship d
ON d.concept_id_1 = c.concept_id AND d.relationship_id = 'Maps to'
LEFT OUTER JOIN xref.concept  e
ON d.concept_id_2 = e.concept_id AND e.standard_concept = 'S'
;

INSERT INTO temp.metadata_temp(
	 [metadata_concept_id]
	,[metadata_type_concept_id]
	,[name]
	,[value_as_string]
	,[value_as_concept_id]
	,[metadata_date]
	,[metadata_datetime]
)
SELECT DISTINCT 
	concept_id as metadata_concept_id 
	,1147636 as metadata_type_concept_id
	,concept_name as name
	,NULL as value_as_string
	,NULL as value_as_concept_id
	,CAST(a.naaccr_item_value AS date) as metadata_date
	,CAST(a.naaccr_item_value AS datetime) as metadata_datetime
FROM temp.naaccr_data_points_temp a
JOIN xref.CONCEPT b
ON a.naaccr_item_number = b.concept_code
AND vocabulary_id = 'naaccr'
AND domain_id = 'Metadata'
--LEFT JOIN xref.CONCEPT_RELATIONSHIP c
--on b.concept_id = c.concept_id_1 and relationship_id = 'Start date of'


INSERT INTO temp.fact_relationship_temp
(
	domain_concept_id_1
	, fact_id_1
	, domain_concept_id_2
	, fact_id_2
	, relationship_concept_id
	, record_id
)
SELECT
	 32527 AS domain_concept_id_1			-- Episode
	,ep.episode_id AS fact_id_1
	,27 AS domain_concept_id_2				-- Observation
	,ob.observation_id AS fact_id_2
	,44818750 AS relationship_concept_id	-- Has occurrence
	,NULL record_id
FROM temp.episode_temp ep
INNER JOIN temp.observation_temp ob
ON ep.person_id = ob.person_id
--AND ep.record_id = ob.record_id
AND ep.episode_concept_id = 32528;			-- Disease First Occurrence

