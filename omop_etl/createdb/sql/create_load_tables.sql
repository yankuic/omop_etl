USE DWS_OMOP

DROP TABLE IF EXISTS dbo.person
CREATE TABLE [dbo].[person](
	[person_id] [int] NOT NULL,
	[gender_concept_id] [int] NOT NULL,
	[year_of_birth] [int] NOT NULL,
	[month_of_birth] [int] NULL,
	[day_of_birth] [int] NULL,
	[birth_datetime] [datetime2](7) NULL,
	[race_concept_id] [int] NOT NULL,
	[ethnicity_concept_id] [int] NOT NULL,
	[location_id] [int] NULL,
	[provider_id] [int] NULL,
	[care_site_id] [int] NULL,
	[person_source_value] [varchar](50) NULL,
	[gender_source_value] [varchar](50) NULL,
	[gender_source_concept_id] [int] NULL,
	[race_source_value] [varchar](50) NULL,
	[race_source_concept_id] [int] NULL,
	[ethnicity_source_value] [varchar](50) NULL,
	[ethnicity_source_concept_id] [int] NULL
) ON [fg_user1]

DROP TABLE IF EXISTS deid.person
CREATE TABLE [dbo].[person](
	[person_id] [int] NOT NULL,
	[gender_concept_id] [int] NOT NULL,
	[year_of_birth] [int] NOT NULL,
	[month_of_birth] [int] NULL,
	[day_of_birth] [int] NULL,
	[birth_datetime] [datetime2](7) NULL,
	[race_concept_id] [int] NOT NULL,
	[ethnicity_concept_id] [int] NOT NULL,
	[location_id] [int] NULL,
	[provider_id] [int] NULL,
	[care_site_id] [int] NULL,
	[person_source_value] [varchar](50) NULL,
	[gender_source_value] [varchar](50) NULL,
	[gender_source_concept_id] [int] NULL,
	[race_source_value] [varchar](50) NULL,
	[race_source_concept_id] [int] NULL,
	[ethnicity_source_value] [varchar](50) NULL,
	[ethnicity_source_concept_id] [int] NULL
) ON [fg_user1]

DROP TABLE IF EXISTS [dbo].[visit_occurrence]
CREATE TABLE [dbo].[visit_occurrence](
	[visit_occurrence_id] [int] NOT NULL,
	[person_id] [int] NOT NULL,
	[visit_concept_id] [int] NOT NULL,
	[visit_start_date] [date] NOT NULL,
	[visit_start_datetime] [datetime2](7) NULL,
	[visit_end_date] [date] NOT NULL,
	[visit_end_datetime] [datetime2](7) NULL,
	[visit_type_concept_id] [int] NOT NULL,
	[provider_id] [int] NULL,
	[care_site_id] [int] NULL,
	[visit_source_value] [varchar](50) NULL,
	[visit_source_concept_id] [int] NULL,
	[admitting_source_concept_id] [int] NULL,
	[admitting_source_value] [varchar](50) NULL,
	[discharge_to_concept_id] [int] NULL,
	[discharge_to_source_value] [varchar](50) NULL,
	[preceding_visit_occurrence_id] [int] NULL
) ON [fg_user1]

DROP TABLE IF EXISTS [deid].[visit_occurrence]
CREATE TABLE [deid].[visit_occurrence](
	[visit_occurrence_id] [int] NOT NULL,
	[person_id] [int] NOT NULL,
	[visit_concept_id] [int] NOT NULL,
	[visit_start_date] [date] NOT NULL,
	[visit_start_datetime] [datetime2](7) NULL,
	[visit_end_date] [date] NOT NULL,
	[visit_end_datetime] [datetime2](7) NULL,
	[visit_type_concept_id] [int] NOT NULL,
	[provider_id] [int] NULL,
	[care_site_id] [int] NULL,
	[visit_source_value] [varchar](50) NULL,
	[visit_source_concept_id] [int] NULL,
	[admitting_source_concept_id] [int] NULL,
	[admitting_source_value] [varchar](50) NULL,
	[discharge_to_concept_id] [int] NULL,
	[discharge_to_source_value] [varchar](50) NULL,
	[preceding_visit_occurrence_id] [int] NULL
) ON [fg_user1]

DROP TABLE IF EXISTS preload.condition_occurrence
CREATE TABLE [preload].[condition_occurrence](
	[person_id] [int] NOT NULL,
	[condition_concept_id] [int] NOT NULL,
	[condition_start_date] [date] NOT NULL,
	[condition_start_datetime] [datetime2](7) NULL,
	[condition_end_date] [date] NULL,
	[condition_end_datetime] [datetime2](7) NULL,
	[condition_type_concept_id] [int] NOT NULL,
	[stop_reason] [varchar](20) NULL,
	[provider_id] [int] NULL,
	[visit_occurrence_id] [int] NULL,
	[visit_detail_id] [int] NULL,
	[condition_source_value] [varchar](50) NULL,
	[condition_source_concept_id] [int] NULL,
	[condition_status_source_value] [varchar](50) NULL,
	[condition_status_concept_id] [int] NULL
) ON [fg_user1]

DROP TABLE IF EXISTS dbo.condition_occurrence
CREATE TABLE dbo.condition_occurrence(
	[condition_occurrence_id] [int] IDENTITY(1,1) NOT NULL,
	[person_id] [int] NOT NULL,
	[condition_concept_id] [int] NOT NULL,
	[condition_start_date] [date] NOT NULL,
	[condition_start_datetime] [datetime2](7) NULL,
	[condition_end_date] [date] NULL,
	[condition_end_datetime] [datetime2](7) NULL,
	[condition_type_concept_id] [int] NOT NULL,
	[stop_reason] [varchar](20) NULL,
	[provider_id] [int] NULL,
	[visit_occurrence_id] [int] NULL,
	[visit_detail_id] [int] NULL,
	[condition_source_value] [varchar](50) NULL,
	[condition_source_concept_id] [int] NULL,
	[condition_status_source_value] [varchar](50) NULL,
	[condition_status_concept_id] [int] NULL
) ON [fg_user1]

DROP TABLE IF EXISTS [preload].[procedure_occurrence]
CREATE TABLE [preload].[procedure_occurrence](
	[person_id] [int] NOT NULL,
	[procedure_concept_id] [int] NOT NULL,
	[procedure_date] [date] NOT NULL,
	[procedure_datetime] [datetime2](7) NULL,
	[procedure_type_concept_id] [int] NOT NULL,
	[modifier_concept_id] [int] NULL,
	[quantity] [int] NULL,
	[provider_id] [int] NULL,
	[visit_occurrence_id] [int] NULL,
	[visit_detail_id] [int] NULL,
	[procedure_source_value] [varchar](50) NULL,
	[procedure_source_concept_id] [int] NULL,
	[modifier_source_value] [varchar](50) NULL,
	[source_table] [varchar](50) NULL
) ON [fg_user1]

DROP TABLE IF EXISTS [dbo].[procedure_occurrence]
CREATE TABLE [dbo].[procedure_occurrence](
	[procedure_occurrence_id] [int] IDENTITY(1,1) NOT NULL,
	[person_id] [int] NOT NULL,
	[procedure_concept_id] [int] NOT NULL,
	[procedure_date] [date] NOT NULL,
	[procedure_datetime] [datetime2](7) NULL,
	[procedure_type_concept_id] [int] NOT NULL,
	[modifier_concept_id] [int] NULL,
	[quantity] [int] NULL,
	[provider_id] [int] NULL,
	[visit_occurrence_id] [int] NULL,
	[visit_detail_id] [int] NULL,
	[procedure_source_value] [varchar](50) NULL,
	[procedure_source_concept_id] [int] NULL,
	[modifier_source_value] [varchar](50) NULL
) ON [fg_user1]

DROP TABLE IF EXISTS preload.drug_exposure
CREATE TABLE preload.drug_exposure (
    person_id integer NOT NULL, 
    drug_concept_id integer NULL, 
    drug_exposure_start_date date NOT NULL, 
    drug_exposure_start_datetime datetime NULL, 
    drug_exposure_end_date date NOT NULL, 
    drug_exposure_end_datetime datetime NULL, 
    verbatim_end_date date NULL, 
    drug_type_concept_id integer NOT NULL, 
    stop_reason varchar(20) NULL, 
    refills integer NULL, 
    quantity varchar(50) NULL, 
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
    source_table varchar(50) 
) ON [fg_user1]; 

DROP TABLE IF EXISTS dbo.drug_exposure
CREATE TABLE dbo.drug_exposure(
	[drug_exposure_id] [int] IDENTITY(1,1) NOT NULL,
	[person_id] [int] NOT NULL,
	[drug_concept_id] [int] NOT NULL,
	[drug_exposure_start_date] [date] NOT NULL,
	[drug_exposure_start_datetime] [datetime2](7) NULL,
	[drug_exposure_end_date] [date] NOT NULL,
	[drug_exposure_end_datetime] [datetime2](7) NULL,
	[verbatim_end_date] [date] NULL,
	[drug_type_concept_id] [int] NOT NULL,
	[stop_reason] [varchar](20) NULL,
	[refills] [int] NULL,
	[quantity] [float] NULL,
	[days_supply] [int] NULL,
	[sig] [varchar](max) NULL,
	[route_concept_id] [int] NULL,
	[lot_number] [varchar](50) NULL,
	[provider_id] [int] NULL,
	[visit_occurrence_id] [int] NULL,
	[visit_detail_id] [int] NULL,
	[drug_source_value] [varchar](50) NULL,
	[drug_source_concept_id] [int] NULL,
	[route_source_value] [varchar](50) NULL,
	[dose_unit_source_value] [varchar](50) NULL
) ON [fg_user1]

DROP TABLE IF EXISTS [preload].[measurement]
CREATE TABLE [preload].[measurement](
	[person_id] [int] NOT NULL,
	[measurement_concept_id] [int] NOT NULL,
	[measurement_date] [date] NOT NULL,
	[measurement_datetime] [datetime2](7) NULL,
	[measurement_time] [varchar](10) NULL,
	[measurement_type_concept_id] [int] NOT NULL,
	[operator_concept_id] [int] NULL,
	[value_as_number] [float] NULL,
	[value_as_concept_id] [int] NULL,
	[unit_concept_id] [int] NULL,
	[range_low] [float] NULL,
	[range_high] [float] NULL,
	[provider_id] [int] NULL,
	[visit_occurrence_id] [int] NULL,
	[visit_detail_id] [int] NULL,
	[measurement_source_value] [varchar](50) NULL,
	[measurement_source_concept_id] [int] NULL,
	[unit_source_value] [varchar](50) NULL,
	[value_source_value] [varchar](50) NULL,
	[source_table] [varchar](50) NULL
) ON [fg_user1]
GO

DROP TABLE [dbo].[measurement]
CREATE TABLE [dbo].[measurement](
	[measurement_id] [int] IDENTITY(1,1) NOT NULL,
	[person_id] [int] NOT NULL,
	[measurement_concept_id] [int] NOT NULL,
	[measurement_date] [date] NOT NULL,
	[measurement_datetime] [datetime2](7) NULL,
	[measurement_time] [varchar](10) NULL,
	[measurement_type_concept_id] [int] NOT NULL,
	[operator_concept_id] [int] NULL,
	[value_as_number] [float] NULL,
	[value_as_concept_id] [int] NULL,
	[unit_concept_id] [int] NULL,
	[range_low] [float] NULL,
	[range_high] [float] NULL,
	[provider_id] [int] NULL,
	[visit_occurrence_id] [int] NULL,
	[visit_detail_id] [int] NULL,
	[measurement_source_value] [varchar](50) NULL,
	[measurement_source_concept_id] [int] NULL,
	[unit_source_value] [varchar](50) NULL,
	[value_source_value] [varchar](50) NULL
) ON [fg_user1]

CREATE TABLE [preload].[observation](
	[person_id] [int] NOT NULL,
	[observation_concept_id] [int] NOT NULL,
	[observation_date] [date] NOT NULL,
	[observation_datetime] [datetime2](7) NULL,
	[observation_type_concept_id] [int] NOT NULL,
	[value_as_number] [float] NULL,
	[value_as_string] [varchar](60) NULL,
	[value_as_concept_id] [int] NULL,
	[qualifier_concept_id] [int] NULL,
	[unit_concept_id] [int] NULL,
	[provider_id] [int] NULL,
	[visit_occurrence_id] [int] NULL,
	[visit_detail_id] [int] NULL,
	[observation_source_value] [varchar](50) NULL,
	[observation_source_concept_id] [int] NULL,
	[unit_source_value] [varchar](50) NULL,
	[qualifier_source_value] [varchar](50) NULL,
	[source_table] [varchar](50) NULL
) ON [fg_user1]

CREATE TABLE [dbo].[observation](
	[observation_id] [int] identity(1,1) NOT NULL,
	[person_id] [int] NOT NULL,
	[observation_concept_id] [int] NOT NULL,
	[observation_date] [date] NOT NULL,
	[observation_datetime] [datetime2](7) NULL,
	[observation_type_concept_id] [int] NOT NULL,
	[value_as_number] [float] NULL,
	[value_as_string] [varchar](60) NULL,
	[value_as_concept_id] [int] NULL,
	[qualifier_concept_id] [int] NULL,
	[unit_concept_id] [int] NULL,
	[provider_id] [int] NULL,
	[visit_occurrence_id] [int] NULL,
	[visit_detail_id] [int] NULL,
	[observation_source_value] [varchar](50) NULL,
	[observation_source_concept_id] [int] NULL,
	[unit_source_value] [varchar](50) NULL,
	[qualifier_source_value] [varchar](50) NULL
) ON [fg_user1]
