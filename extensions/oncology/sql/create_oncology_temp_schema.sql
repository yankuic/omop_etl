/*****  Preliminary mapping/cleanup  *****/

-- Create temporary tables
IF OBJECT_ID('temp.condition_occurrence_temp', 'U') IS NOT NULL -- Drop temp table if it exists
DROP 
  TABLE temp.condition_occurrence_temp;

CREATE TABLE temp.condition_occurrence_temp (
  condition_occurrence_id BIGINT NOT NULL, 
  person_id BIGINT NOT NULL, 
  condition_concept_id INT NOT NULL, 
  condition_start_date DATE NOT NULL, 
  condition_start_datetime DATETIME NULL, 
  condition_end_date DATE NULL, 
  condition_end_datetime DATETIME NULL, 
  condition_type_concept_id INT NOT NULL, 
  stop_reason VARCHAR(20) NULL, 
  provider_id BIGINT NULL, 
  visit_occurrence_id BIGINT NULL, 
  --1/23/2019 Removing because we are trying to match the EDW's OMOP instance.
  -- visit_detail_id BIGINT NULL ,
  condition_source_value VARCHAR(50) NULL, 
  condition_source_concept_id INT NULL, 
  condition_status_source_value VARCHAR(50) NULL, 
  condition_status_concept_id INT NULL, 
  record_id varchar(255) NULL
);

IF OBJECT_ID('temp.measurement_temp', 'U') IS NOT NULL -- Drop temp table if it exists
DROP 
  TABLE temp.measurement_temp;

CREATE TABLE temp.measurement_temp (
  measurement_id BIGINT NOT NULL, 
  person_id BIGINT NOT NULL, 
  measurement_concept_id INT NOT NULL, 
  measurement_date DATE NOT NULL, 
  measurement_time VARCHAR(10) NULL, 
  measurement_datetime DATETIME NULL, 
  measurement_type_concept_id INT NOT NULL, 
  operator_concept_id INT NULL, 
  value_as_number NUMERIC NULL, 
  value_as_concept_id INT NULL, 
  unit_concept_id INT NULL, 
  range_low NUMERIC NULL, 
  range_high NUMERIC NULL, 
  provider_id BIGINT NULL, 
  visit_occurrence_id BIGINT NULL, 
  visit_detail_id BIGINT NULL, 
  measurement_source_value VARCHAR(50) NULL, 
  measurement_source_concept_id INT NULL, 
  unit_source_value VARCHAR(50) NULL, 
  value_source_value VARCHAR(50) NULL, 
  modifier_of_event_id BIGINT NULL, 
  modifier_of_field_concept_id INT NULL, 
  record_id VARCHAR(255) NULL
);

IF OBJECT_ID('temp.episode_temp', 'U') IS NOT NULL -- Drop temp table if it exists
DROP 
  TABLE temp.episode_temp;

CREATE TABLE temp.episode_temp (
  episode_id BIGINT NOT NULL, 
  person_id BIGINT NOT NULL, 
  episode_concept_id INT NOT NULL, 
  episode_start_datetime DATETIME NULL, 
  --Fix me
  episode_end_datetime DATETIME NULL, 
  episode_parent_id BIGINT NULL, 
  episode_number INTEGER NULL, 
  episode_object_concept_id INTEGER NOT NULL, 
  episode_type_concept_id INTEGER NOT NULL, 
  episode_source_value VARCHAR(50) NULL, 
  episode_source_concept_id INTEGER NULL, 
  record_id VARCHAR(255) NULL
);

IF OBJECT_ID('temp.episode_event_temp', 'U') IS NOT NULL -- Drop temp table if it exists
DROP 
  TABLE temp.episode_event_temp;

CREATE TABLE temp.episode_event_temp (
  episode_id BIGINT NOT NULL, 
  event_id BIGINT NOT NULL, 
  episode_event_field_concept_id INT NOT NULL
);

IF OBJECT_ID('temp.procedure_occurrence_temp', 'U') IS NOT NULL -- Drop temp table if it exists
DROP 
  TABLE temp.procedure_occurrence_temp;

CREATE TABLE temp.procedure_occurrence_temp (
  procedure_occurrence_id BIGINT NOT NULL, 
  person_id BIGINT NOT NULL, 
  procedure_concept_id INT NOT NULL, 
  procedure_date DATE NOT NULL, 
  procedure_datetime DATETIME NULL, 
  procedure_type_concept_id INT NOT NULL, 
  modifier_concept_id INT NULL, 
  quantity BIGINT NULL, 
  provider_id BIGINT NULL, 
  visit_occurrence_id BIGINT NULL, 
  visit_detail_id BIGINT NULL, 
  procedure_source_value VARCHAR(50) NULL, 
  procedure_source_concept_id INT NULL, 
  modifier_source_value VARCHAR(50) NULL, 
  episode_id BIGINT NOT NULL, 
  record_id VARCHAR(255) NULL
);

IF OBJECT_ID('temp.drug_exposure_temp', 'U') IS NOT NULL -- Drop temp table if it exists
DROP 
  TABLE temp.drug_exposure_temp;

CREATE TABLE temp.drug_exposure_temp (
  drug_exposure_id BIGINT NOT NULL, 
  person_id BIGINT NOT NULL, 
  drug_concept_id INT NOT NULL, 
  drug_exposure_start_date DATE NOT NULL, 
  drug_exposure_start_datetime DATETIME NULL, 
  drug_exposure_end_date DATE NULL, 
  drug_exposure_end_datetime DATETIME NULL, 
  verbatim_end_date DATE NULL, 
  drug_type_concept_id INT NOT NULL, 
  stop_reason VARCHAR(20) NULL, 
  refills BIGINT NULL, 
  quantity NUMERIC NULL, 
  days_supply BIGINT NULL, 
  sig TEXT NULL, 
  route_concept_id INT NULL, 
  lot_number VARCHAR(50) NULL, 
  provider_id BIGINT NULL, 
  visit_occurrence_id BIGINT NULL, 
  visit_detail_id BIGINT NULL, 
  drug_source_value VARCHAR(50) NULL, 
  drug_source_concept_id INT NULL, 
  route_source_value VARCHAR(50) NULL, 
  dose_unit_source_value VARCHAR(50) NULL, 
  record_id VARCHAR(255) NULL
);

IF OBJECT_ID('temp.observation_period_temp', 'U') IS NOT NULL -- Drop temp table if it exists
DROP 
  TABLE temp.observation_period_temp;

CREATE TABLE temp.observation_period_temp (
  observation_period_id INT NOT NULL, 
  person_id INT NOT NULL, observation_period_start_date DATE NOT NULL, 
  observation_period_end_date DATE NOT NULL, 
  period_type_concept_id INT NOT NULL
);

IF OBJECT_ID('temp.observation_temp', 'U') IS NOT NULL -- Drop temp table if it exists
DROP 
  TABLE temp.observation_temp;

CREATE TABLE temp.observation_temp (
  observation_id BIGINT NOT NULL, 
  person_id BIGINT NOT NULL, 
  observation_concept_id INT NOT NULL, 
  observation_date DATE NULL, 
  observation_datetime DATETIME NULL, 
  observation_type_concept_id INT NULL, 
  value_as_number NUMERIC NULL, 
  value_as_string VARCHAR(255) NULL, 
  value_as_concept_id INT NULL, 
  qualifier_concept_id INT NULL, 
  unit_concept_id INT NULL, 
  provider_id BIGINT NULL, 
  visit_occurrence_id BIGINT NULL, 
  visit_detail_id BIGINT NULL, 
  observation_source_value VARCHAR(50) NULL, 
  observation_source_concept_id INT NULL, 
  unit_source_value VARCHAR(50) NULL, 
  qualifier_source_value VARCHAR(255) NULL, 
  -- observation_event_id         BIGINT       NULL ,
  -- obs_event_field_concept_id   BIGINT       NULL ,
  -- value_as_datetime            BIGINT       NULL ,
  record_id VARCHAR(255) NULL
);

IF OBJECT_ID('temp.fact_relationship_temp', 'U') IS NOT NULL -- Drop temp table if it exists
DROP 
  TABLE temp.fact_relationship_temp;

CREATE TABLE temp.fact_relationship_temp (
  domain_concept_id_1 INT NOT NULL, 
  fact_id_1 BIGINT NOT NULL, 
  domain_concept_id_2 INT NOT NULL, 
  fact_id_2 BIGINT NOT NULL, 
  relationship_concept_id INT NOT NULL, 
  record_id VARCHAR(255) NULL
);

-- Create ambiguous schema discriminator mapping tables
IF OBJECT_ID('temp.ambig_schema_discrim', 'U') IS NOT NULL -- Drop temp table if it exists
DROP 
  TABLE temp.ambig_schema_discrim;

CREATE TABLE temp.ambig_schema_discrim(
  schema_concept_code varchar(50) NULL, 
  schema_concept_id INT NULL, 
  discrim_item_num varchar(50) NULL, 
  discrim_item_value varchar(50) NULL
);

-- Populate table
INSERT INTO temp.ambig_schema_discrim (schema_concept_code, schema_concept_id,
discrim_item_num, discrim_item_value)
  VALUES ('stomach', 35909803, '2879', '000');
INSERT INTO temp.ambig_schema_discrim (schema_concept_code, schema_concept_id,
discrim_item_num, discrim_item_value)
  VALUES ('stomach', 35909803, '2879', '030');
INSERT INTO temp.ambig_schema_discrim (schema_concept_code, schema_concept_id,
discrim_item_num, discrim_item_value)
  VALUES ('stomach', 35909803, '2879', '981');
INSERT INTO temp.ambig_schema_discrim (schema_concept_code, schema_concept_id,
discrim_item_num, discrim_item_value)
  VALUES ('stomach', 35909803, '2879', '999');
INSERT INTO temp.ambig_schema_discrim (schema_concept_code, schema_concept_id,
discrim_item_num, discrim_item_value)
  VALUES ('esophagus_gejunction', 35909724, '2879', '020');
INSERT INTO temp.ambig_schema_discrim (schema_concept_code, schema_concept_id,
discrim_item_num, discrim_item_value)
  VALUES ('esophagus_gejunction', 35909724, '2879', '040');
INSERT INTO temp.ambig_schema_discrim (schema_concept_code, schema_concept_id,
discrim_item_num, discrim_item_value)
  VALUES ('esophagus_gejunction', 35909724, '2879', '982');
INSERT INTO temp.ambig_schema_discrim (schema_concept_code, schema_concept_id,
discrim_item_num, discrim_item_value)
  VALUES ('bile_ducts_distal', 35909746, '2879', '040');
INSERT INTO temp.ambig_schema_discrim (schema_concept_code, schema_concept_id,
discrim_item_num, discrim_item_value)
  VALUES ('bile_ducts_distal', 35909746, '2879', '070');
INSERT INTO temp.ambig_schema_discrim (schema_concept_code, schema_concept_id,
discrim_item_num, discrim_item_value)
  VALUES ('bile_ducts_perihilar', 35909846, '2879', '010');
INSERT INTO temp.ambig_schema_discrim (schema_concept_code, schema_concept_id,
discrim_item_num, discrim_item_value)
  VALUES ('bile_ducts_perihilar', 35909846, '2879', '020');
INSERT INTO temp.ambig_schema_discrim (schema_concept_code, schema_concept_id,
discrim_item_num, discrim_item_value)
  VALUES ('bile_ducts_perihilar', 35909846, '2879', '050');
INSERT INTO temp.ambig_schema_discrim (schema_concept_code, schema_concept_id,
discrim_item_num, discrim_item_value)
  VALUES ('bile_ducts_perihilar', 35909846, '2879', '060');
INSERT INTO temp.ambig_schema_discrim (schema_concept_code, schema_concept_id,
discrim_item_num, discrim_item_value)
  VALUES ('bile_ducts_perihilar', 35909846, '2879', '999');
INSERT INTO temp.ambig_schema_discrim (schema_concept_code, schema_concept_id,
discrim_item_num, discrim_item_value)
  VALUES ('cystic_duct', 35909773, '2879', '030');
INSERT INTO temp.ambig_schema_discrim (schema_concept_code, schema_concept_id,
discrim_item_num, discrim_item_value)
  VALUES ('lacrimal_gland', 35909735, '2879', '015');
INSERT INTO temp.ambig_schema_discrim (schema_concept_code, schema_concept_id,
discrim_item_num, discrim_item_value)
  VALUES ('lacrimal_sac', 35909739, '2879', '025');
INSERT INTO temp.ambig_schema_discrim (schema_concept_code, schema_concept_id,
discrim_item_num, discrim_item_value)
  VALUES ('melanoma_ciliary_body', 35909820, '2879', '010');
INSERT INTO temp.ambig_schema_discrim (schema_concept_code, schema_concept_id,
discrim_item_num, discrim_item_value)
  VALUES ('melanoma_iris', 35909687, '2879', '020');
INSERT INTO temp.ambig_schema_discrim (schema_concept_code, schema_concept_id,
discrim_item_num, discrim_item_value)
  VALUES ('nasopharynx', 35909813, '2879', '010');
INSERT INTO temp.ambig_schema_discrim (schema_concept_code, schema_concept_id,
discrim_item_num, discrim_item_value)
  VALUES ('nasopharynx', 35909813, '2879', '981');
INSERT INTO temp.ambig_schema_discrim (schema_concept_code, schema_concept_id,
discrim_item_num, discrim_item_value)
  VALUES ('pharyngeal_tonsil', 35909780, '2879', '020');
INSERT INTO temp.ambig_schema_discrim (schema_concept_code, schema_concept_id,
discrim_item_num, discrim_item_value)
  VALUES ('peritoneum', 35909796, '220', '1');
INSERT INTO temp.ambig_schema_discrim (schema_concept_code, schema_concept_id,
discrim_item_num, discrim_item_value)
  VALUES ('peritoneum', 35909796, '220', '3');
INSERT INTO temp.ambig_schema_discrim (schema_concept_code, schema_concept_id,
discrim_item_num, discrim_item_value)
  VALUES ('peritoneum', 35909796, '220', '4');
INSERT INTO temp.ambig_schema_discrim (schema_concept_code, schema_concept_id,
discrim_item_num, discrim_item_value)
  VALUES ('peritoneum', 35909796, '220', '5');
INSERT INTO temp.ambig_schema_discrim (schema_concept_code, schema_concept_id,
discrim_item_num, discrim_item_value)
  VALUES ('peritoneum', 35909796, '220', '9');
INSERT INTO temp.ambig_schema_discrim (schema_concept_code, schema_concept_id,
discrim_item_num, discrim_item_value)
  VALUES ('peritoneum_female_gen', 35909817, '220', '2');
INSERT INTO temp.ambig_schema_discrim (schema_concept_code, schema_concept_id,
discrim_item_num, discrim_item_value)
  VALUES ('peritoneum_female_gen', 35909817, '220', '6');

IF OBJECT_ID('temp.naaccr_data_points_temp', 'U') IS NOT NULL -- Drop temp table if it exists
DROP 
  TABLE temp.naaccr_data_points_temp;

CREATE TABLE temp.naaccr_data_points_temp (
  person_id BIGINT NOT NULL, 
  record_id VARCHAR(255) NULL, 
  histology_site VARCHAR(255) NULL, 
  naaccr_item_number VARCHAR(255) NULL, 
  naaccr_item_value VARCHAR(255) NULL, 
  schema_concept_id INT NULL, 
  schema_concept_code VARCHAR(255), 
  variable_concept_id INT NULL, 
  variable_concept_code VARCHAR(255) NULL, 
  value_concept_id INT NULL, 
  value_concept_code VARCHAR(255) NULL, 
  type_concept_id INT NULL
);

IF OBJECT_ID('temp.tmp_naaccr_data_points_temp_dates', 'U') IS NOT NULL -- Drop temp table if it exists
DROP 
  TABLE temp.tmp_naaccr_data_points_temp_dates;

CREATE TABLE temp.tmp_naaccr_data_points_temp_dates (
  person_id BIGINT NOT NULL, 
  record_id VARCHAR(255) NULL, 
  histology_site VARCHAR(255) NULL, 
  naaccr_item_number VARCHAR(255) NULL, 
  naaccr_item_value VARCHAR(255) NULL, 
  schema_concept_id INT NULL, 
  schema_concept_code VARCHAR(255), 
  variable_concept_id INT NULL, 
  variable_concept_code VARCHAR(255) NULL, 
  value_concept_id INT NULL, 
  value_concept_code VARCHAR(255) NULL, 
  type_concept_id INT NULL
);

IF OBJECT_ID('temp.tmp_concept_naaccr_procedures', 'U') IS NOT NULL -- Drop temp table if it exists
DROP 
  TABLE temp.tmp_concept_naaccr_procedures;

CREATE TABLE temp.tmp_concept_naaccr_procedures (
  c1_concept_id INT NULL, 
  c1_concept_code VARCHAR(255), 
  c2_concept_id INT NULL, 
  c2_concept_code VARCHAR(255)
);

IF OBJECT_ID('temp.metadata_temp', 'U') IS NOT NULL
DROP 
	TABLE temp.metadata_temp;

CREATE TABLE [temp].[metadata_temp](
	[metadata_concept_id] [int] NOT NULL,
	[metadata_type_concept_id] [int] NOT NULL,
	[name] [varchar](250) NOT NULL,
	[value_as_string] [varchar](250) NULL,
	[value_as_concept_id] [int] NULL,
	[metadata_date] [date] NULL,
	[metadata_datetime] [datetime] NULL
) ON [fg_user1]
;
