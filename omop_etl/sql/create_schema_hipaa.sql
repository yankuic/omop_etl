--sql server CDM DDL Specification for OMOP Common Data Model v5_3_1
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'hipaa')
BEGIN
	EXEC( 'CREATE SCHEMA hipaa' );
END

--HINT DISTRIBUTE ON KEY (person_id)
 CREATE TABLE hipaa.PERSON (

    person_id integer NOT NULL,
    gender_concept_id integer NOT NULL,
    year_of_birth integer NOT NULL,
    month_of_birth integer NULL,
    day_of_birth integer NULL,
    birth_datetime datetime NULL,
    race_concept_id integer NOT NULL,
    ethnicity_concept_id integer NOT NULL,
    location_id integer NULL,
    provider_id integer NULL,
    care_site_id integer NULL,
    person_source_value varchar(50) NULL,
    gender_source_value varchar(50) NULL,
    gender_source_concept_id integer NULL,
    race_source_value varchar(50) NULL,
    race_source_concept_id integer NULL,
    ethnicity_source_value varchar(50) NULL,
    ethnicity_source_concept_id integer NULL 

) ON fg_user1;

--HINT DISTRIBUTE ON KEY (person_id)
 CREATE TABLE hipaa.OBSERVATION_PERIOD (

    observation_period_id integer IDENTITY(1,1) NOT NULL,
    person_id integer NOT NULL,
    observation_period_start_date date NOT NULL,
    observation_period_end_date date NOT NULL,
    period_type_concept_id integer NOT NULL 

) ON fg_user1;

--HINT DISTRIBUTE ON KEY (person_id)
 CREATE TABLE hipaa.VISIT_OCCURRENCE (

    visit_occurrence_id integer NOT NULL,
    person_id integer NOT NULL,
    visit_concept_id integer NOT NULL,
    visit_start_date date NOT NULL,
    visit_start_datetime datetime NULL,
    visit_end_date date NOT NULL,
    visit_end_datetime datetime NULL,
    visit_type_concept_id Integer NOT NULL,
    provider_id integer NULL,
    care_site_id integer NULL,
    visit_source_value varchar(50) NULL,
    visit_source_concept_id integer NULL,
    admitting_source_concept_id integer NULL,
    admitting_source_value varchar(50) NULL,
    discharge_to_concept_id integer NULL,
    discharge_to_source_value varchar(50) NULL,
    preceding_visit_occurrence_id integer NULL 

) ON fg_user1;

--HINT DISTRIBUTE ON KEY (person_id)
 CREATE TABLE hipaa.CONDITION_OCCURRENCE (

    condition_occurrence_id integer IDENTITY(1,1) NOT NULL,
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
    condition_source_concept_id integer NULL,
    condition_status_source_value varchar(50) NULL 

) ON fg_user1;

--HINT DISTRIBUTE ON KEY (person_id)
 CREATE TABLE hipaa.DRUG_EXPOSURE (

    drug_exposure_id integer IDENTITY(1,1) NOT NULL,
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
    dose_unit_source_value varchar(50) NULL 

) ON fg_user1;

--HINT DISTRIBUTE ON KEY (person_id)
 CREATE TABLE hipaa.PROCEDURE_OCCURRENCE (

    procedure_occurrence_id integer IDENTITY(1,1) NOT NULL,
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
    modifier_source_value varchar(50) NULL 

) ON fg_user1;

--HINT DISTRIBUTE ON KEY (person_id)
 CREATE TABLE hipaa.DEVICE_EXPOSURE (

    device_exposure_id integer IDENTITY(1,1) NOT NULL,
    person_id integer NOT NULL,
    device_concept_id integer NOT NULL,
    device_exposure_start_date date NOT NULL,
    device_exposure_start_datetime datetime NULL,
    device_exposure_end_date date NULL,
    device_exposure_end_datetime datetime NULL,
    device_type_concept_id integer NOT NULL,
    unique_device_id varchar(100) NULL,
    quantity integer NULL,
    provider_id integer NULL,
    visit_occurrence_id integer NULL,
    visit_detail_id integer NULL,
    device_source_value varchar(100) NULL,
    device_source_concept_id integer NULL 

) ON fg_user1;

--HINT DISTRIBUTE ON KEY (person_id)
 CREATE TABLE hipaa.MEASUREMENT (

    measurement_id integer IDENTITY(1,1) NOT NULL,
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
    value_source_value varchar(50) NULL 

) ON fg_user1;

--HINT DISTRIBUTE ON KEY (person_id)
 CREATE TABLE hipaa.OBSERVATION (

    observation_id integer IDENTITY(1,1) NOT NULL,
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
    qualifier_source_value varchar(50) NULL 

) ON fg_user1;

--HINT DISTRIBUTE ON KEY (person_id)
 CREATE TABLE hipaa.DEATH (

    person_id integer NULL,
    death_date date NULL,
    death_datetime datetime NULL,
    death_type_concept_id integer NULL,
    cause_concept_id integer NULL,
    cause_source_value varchar(50) NULL,
    cause_source_concept_id integer NULL 

) ON fg_user1;

--HINT DISTRIBUTE ON KEY (person_id)
 CREATE TABLE hipaa.NOTE (

    note_id integer NOT NULL,
    person_id integer NOT NULL,
    note_date date NOT NULL,
    note_datetime datetime NULL,
    note_type_concept_id integer NOT NULL,
    note_class_concept_id integer NOT NULL,
    note_title varchar(250) NULL,
    note_text varchar(MAX) NOT NULL,
    encoding_concept_id integer NOT NULL,
    language_concept_id integer NOT NULL,
    provider_id integer NULL,
    visit_occurrence_id integer NULL,
    visit_detail_id integer NULL,
    note_source_value varchar(50) NULL 

) ON fg_user1;

--HINT DISTRIBUTE ON RANDOM
 CREATE TABLE hipaa.LOCATION (

    location_id integer NOT NULL,
    address_1 varchar(50) NULL,
    address_2 varchar(50) NULL,
    city varchar(50) NULL,
    state varchar(2) NULL,
    zip varchar(9) NULL,
    county varchar(20) NULL,
    location_source_value varchar(50) NULL 

) ON fg_user1;

--HINT DISTRIBUTE ON RANDOM
 CREATE TABLE hipaa.CARE_SITE (

    care_site_id integer NOT NULL,
    care_site_name varchar(255) NULL,
    place_of_service_concept_id integer NULL,
    location_id integer NULL,
    care_site_source_value varchar(50) NULL,
    place_of_service_source_value varchar(50) NULL 

) ON fg_user1;

--HINT DISTRIBUTE ON RANDOM
 CREATE TABLE hipaa.PROVIDER (

    provider_id integer NOT NULL,
    provider_name varchar(255) NULL,
    npi varchar(20) NULL,
    dea varchar(20) NULL,
    specialty_concept_id integer NULL,
    care_site_id integer NULL,
    year_of_birth integer NULL,
    gender_concept_id integer NULL,
    provider_source_value varchar(50) NULL,
    specialty_source_value varchar(50) NULL,
    specialty_source_concept_id integer NULL,
    gender_source_value varchar(50) NULL,
    gender_source_concept_id integer NULL 

) ON fg_user1;
