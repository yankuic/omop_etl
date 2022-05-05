/*********************
This is DDL for the NAACCR ETL SQL input format.  
The NAACCR ETL SQL assumes you have converted your NAACCR data into this structure.
Source: https://github.com/OHDSI/OncologyWG/blob/master/etl/naaccr_etl_input_format_ddl.sql
*********************/
CREATE TABLE preload.NAACCR_DATA_POINTS(
    person_id            BIGINT,
    record_id            varchar(255) NULL,
    naaccr_item_number   varchar(255) NULL,
    naaccr_item_value    varchar(255) NULL,
    histology            varchar(255) NULL,
    site  varchar(255) NULL,
    histology_site       varchar(255) NULL
) on [fg_user1];


--source: https://github.com/OHDSI/OncologyWG/blob/master/ddl/Sql%20Server/OMOP%20CDM%20sql%20server%20ddl%20Oncology%20Module.txt
/************************
Standardized vocabulary
************************/
--HINT DISTRIBUTE ON RANDOM
CREATE TABLE xref.CONCEPT_NUMERIC (
  concept_id          INTEGER       NOT NULL,
  value_as_number     FLOAT         NULL,
  unit_concept_id     INTEGER       NULL,
  operator_concept_id INTEGER       NULL
) on [fg_user1]
;

--This is DDL for the NAACCR ETL SQL provenance format.
--from https://github.com/OHDSI/OncologyWG/blob/master/etl/cdm_source_provenance.sql
CREATE TABLE xref.cdm_source_provenance(
  cdm_event_id           BIGINT NOT NULL,
  cdm_field_concept_id   INTEGER NOT NULL,
  record_id              varchar(255) NOT NULL
);

/************************
Standardized clinical data
************************/
--HINT DISTRIBUTE_ON_KEY(person_id)
CREATE TABLE dbo.EPISODE (
	episode_id   BIGINT      NOT NULL,
	person_id    BIGINT      NOT NULL,
	episode_concept_id          INTEGER     NOT NULL,
	episode_start_datetime      DATETIME2 	NOT NULL,
	episode_end_datetime        DATETIME2 	NULL,
	episode_parent_id           BIGINT      NULL,
	episode_number              INTEGER     NULL,
	episode_object_concept_id   INTEGER     NOT NULL,
	episode_type_concept_id     INTEGER     NOT NULL,
	episode_source_value        VARCHAR(50) NULL,
	episode_source_concept_id   INTEGER 	NULL
)  on [fg_user1]
;

--HINT DISTRIBUTE ON RANDOM
CREATE TABLE dbo.EPISODE_EVENT (
    episode_id       BIGINT 	NOT NULL,
    event_id 		 BIGINT 	NOT NULL,
    episode_event_field_concept_id  INTEGER NOT NULL
)  on [fg_user1]
;

--HINT DISTRIBUTE_ON_KEY(person_id)
--CREATE TABLE dbo.measurement
--(
--    measurement_id BIGINT      NOT NULL ,
--    person_id      BIGINT      NOT NULL ,
--    measurement_concept_id        INTEGER     NOT NULL ,
--    measurement_date              DATE        NULL ,
--    measurement_datetime          DATETIME2   NOT NULL ,
--    measurement_time              VARCHAR(10) NULL,
--    measurement_type_concept_id	  INTEGER     NOT NULL ,
--    operator_concept_id           INTEGER     NULL ,
--    value_as_number               FLOAT       NULL ,
--    value_as_concept_id           INTEGER     NULL ,
--    unit_concept_id               INTEGER     NULL ,
--    range_low      FLOAT       NULL ,
--    range_high     FLOAT       NULL ,
--    provider_id    BIGINT      NULL ,
--    visit_occurrence_id           BIGINT      NULL ,
--    visit_detail_id               BIGINT      NULL ,
--    measurement_source_value	  VARCHAR(50) NULL ,
--    measurement_source_concept_id INTEGER     NOT NULL ,
--    unit_source_value             VARCHAR(50) NULL ,
--    value_source_value            VARCHAR(50) NULL,
--    modifier_of_event_id          BIGINT      NULL,
--    modifier_of_field_concept_id  INTEGER     NULL
--)  on [fg_user1]
--;

/*Measurement ALTER statement.  
When you are not starting from scratch.*/
ALTER TABLE MEASUREMENT 
ADD modifier_of_event_id BIGINT NULL, modifier_of_field_concept_id INTEGER NULL;
