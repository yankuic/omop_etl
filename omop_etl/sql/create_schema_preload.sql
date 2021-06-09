--sql server CDM DDL Specification for OMOP Common Data Model v5_3_1

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'preload')
BEGIN
	EXEC( 'CREATE SCHEMA preload' );
END

--HINT DISTRIBUTE ON KEY (person_id)
 CREATE TABLE preload.CONDITION_OCCURRENCE (

	person_id integer NOT NULL,
	condition_concept_id integer NOT NULL,
	condition_start_date date NOT NULL,
	condition_start_datetime datetime NULL,
	condition_end_date date NULL,
	condition_end_datetime datetime NULL,
	condition_type_concept_id integer NOT NULL,
	condition_status_concept_id integer NULL,
	stop_reason varchar(20) NULL,
	provider_id integer NULL,
	visit_occurrence_id integer NULL,
	visit_detail_id integer NULL,
	condition_source_value varchar(50) NULL,
	condition_status_source_value varchar(50) NULL,
	condition_source_concept_id integer NULL

) ON fg_user1;

--HINT DISTRIBUTE ON KEY (person_id)
 CREATE TABLE preload.DRUG_EXPOSURE (

			person_id integer NOT NULL,
			drug_concept_id integer NOT NULL,
			drug_exposure_start_date date NOT NULL,
			drug_exposure_start_datetime datetime NULL,
			drug_exposure_end_date date NOT NULL,
			drug_exposure_end_datetime datetime NULL,
			verbatim_end_date date NULL,
			drug_type_concept_id integer NOT NULL,
			stop_reason varchar(20) NULL,
			refills integer NULL,
			quantity float NULL,
			days_supply integer NULL,
			sig varchar(MAX) NULL,
			route_concept_id integer NULL,
			lot_number varchar(50) NULL,
			provider_id integer NULL,
			visit_occurrence_id integer NULL,
			visit_detail_id integer NULL,
			drug_source_value varchar(50) NULL,
			drug_source_concept_id integer NULL,
			route_source_value varchar(50) NULL,
			dose_unit_source_value varchar(50) NULL,
            source_table varchar(50) NULL );

--HINT DISTRIBUTE ON KEY (person_id)
 CREATE TABLE preload.PROCEDURE_OCCURRENCE (

			person_id integer NOT NULL,
			procedure_concept_id integer NOT NULL,
			procedure_date date NOT NULL,
			procedure_datetime datetime NULL,
			procedure_type_concept_id integer NOT NULL,
			modifier_concept_id integer NULL,
			quantity integer NULL,
			provider_id integer NULL,
			visit_occurrence_id integer NULL,
			visit_detail_id integer NULL,
			procedure_source_value varchar(50) NULL,
			procedure_source_concept_id integer NULL,
			modifier_source_value varchar(50) NULL,
            source_table varchar(50) NULL );


--HINT DISTRIBUTE ON KEY (person_id)
 CREATE TABLE preload.MEASUREMENT (

			person_id integer NOT NULL,
			measurement_concept_id integer NOT NULL,
			measurement_date date NOT NULL,
			measurement_datetime datetime NULL,
			measurement_time varchar(10) NULL,
			measurement_type_concept_id integer NOT NULL,
			operator_concept_id integer NULL,
			value_as_number float NULL,
			value_as_concept_id integer NULL,
			unit_concept_id integer NULL,
			range_low float NULL,
			range_high float NULL,
			provider_id integer NULL,
			visit_occurrence_id integer NULL,
			visit_detail_id integer NULL,
			measurement_source_value varchar(50) NULL,
			measurement_source_concept_id integer NULL,
			unit_source_value varchar(50) NULL,
			value_source_value varchar(50) NULL,
            source_table varchar(50) NULL  );

--HINT DISTRIBUTE ON KEY (person_id)
 CREATE TABLE preload.OBSERVATION (

			person_id integer NOT NULL,
			observation_concept_id integer NOT NULL,
			observation_date date NOT NULL,
			observation_datetime datetime NULL,
			observation_type_concept_id integer NOT NULL,
			value_as_number float NULL,
			value_as_string varchar(60) NULL,
			value_as_concept_id Integer NULL,
			qualifier_concept_id integer NULL,
			unit_concept_id integer NULL,
			provider_id integer NULL,
			visit_occurrence_id integer NULL,
			visit_detail_id integer NULL,
			observation_source_value varchar(50) NULL,
			observation_source_concept_id integer NULL,
			unit_source_value varchar(50) NULL,
			qualifier_source_value varchar(50) NULL,
            source_table varchar(50) NULL );
