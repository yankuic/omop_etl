IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'xref')
BEGIN
	EXEC( 'CREATE SCHEMA xref' );
END

--- MAPPING TABLES ---
CREATE TABLE [xref].[person_mapping](
	
    [person_id] [int] IDENTITY(1,1) NOT NULL,
	[patient_key] [int] NULL,
	[date_shift] [int] NULL,
	[load_dt] [datetime2](7) NULL,
	[merge_ind] [varchar](1) NULL,
	[merge_dt] [datetime2](7) NULL,
	[active_ind] [varchar](1) NULL,
    CONSTRAINT [xpk_person_mapping] PRIMARY KEY CLUSTERED 
    (
        [person_id] ASC
    ) WITH (
        PAD_INDEX = OFF, 
        STATISTICS_NORECOMPUTE = OFF, 
        IGNORE_DUP_KEY = OFF, 
        ALLOW_ROW_LOCKS = ON, 
        ALLOW_PAGE_LOCKS = ON
    ) ON [fg_user1]

) ON [fg_user1]

CREATE TABLE [xref].[visit_occurrence_mapping](

	[visit_occurrence_id] [int] IDENTITY(1,1) NOT NULL,
	[patnt_encntr_key] [decimal](18, 0) NULL,
	[load_dt] [datetime2](7) NULL,
	[active_ind] [varchar](1) NULL,
    CONSTRAINT [xpk_visit_occurrence_mapping] PRIMARY KEY CLUSTERED      
    (
        [visit_occurrence_id] ASC
    ) WITH (
        PAD_INDEX = OFF, 
        STATISTICS_NORECOMPUTE = OFF, 
        IGNORE_DUP_KEY = OFF, 
        ALLOW_ROW_LOCKS = ON, 
        ALLOW_PAGE_LOCKS = ON
    ) ON [fg_user1]

) ON [fg_user1]

CREATE TABLE [xref].[care_site_mapping](

	[care_site_id] [int] IDENTITY(1,1) NOT NULL,
	[dept_id] [varchar](250) NULL,
	[load_dt] [datetime2](7) NULL,
	[active_ind] [varchar](1) NULL,
    CONSTRAINT [xpk_care_site_mapping] PRIMARY KEY CLUSTERED 
    (
	    [care_site_id] ASC
    ) WITH (
        PAD_INDEX = OFF, 
        STATISTICS_NORECOMPUTE = OFF, 
        IGNORE_DUP_KEY = OFF, 
        ALLOW_ROW_LOCKS = ON, 
        ALLOW_PAGE_LOCKS = ON
    ) ON [fg_user1]

) ON [fg_user1]

CREATE TABLE [xref].[location_mapping](

	[location_id] [int] IDENTITY(1,1) NOT NULL,
	[addr_key] [decimal](18, 0) NULL,
	[load_dt] [datetime2](7) NULL,
	[active_ind] [varchar](1) NULL,
     CONSTRAINT [xpk_location_mapping] PRIMARY KEY CLUSTERED 
    (
	    [location_id] ASC
    ) WITH (
        PAD_INDEX = OFF, 
        STATISTICS_NORECOMPUTE = OFF, 
        IGNORE_DUP_KEY = OFF, 
        ALLOW_ROW_LOCKS = ON, 
        ALLOW_PAGE_LOCKS = ON
    ) ON [fg_user1]

) ON [fg_user1]


CREATE TABLE [xref].[provider_mapping](

	[provider_id] [int] IDENTITY(1,1) NOT NULL,
	[providr_key] [decimal](18, 0) NULL,
	[load_dt] [datetime2](7) NULL,
	[active_ind] [varchar](1) NULL,
    CONSTRAINT [xpk_provider_mapping] PRIMARY KEY CLUSTERED 
    (
        [provider_id] ASC
    ) WITH (
        PAD_INDEX = OFF, 
        STATISTICS_NORECOMPUTE = OFF, 
        IGNORE_DUP_KEY = OFF, 
        ALLOW_ROW_LOCKS = ON, 
        ALLOW_PAGE_LOCKS = ON
    ) ON [fg_user1]

) ON [fg_user1]


--- CDM tables ---

--HINT DISTRIBUTE ON RANDOM
 CREATE TABLE xref.CONCEPT (

    concept_id integer NOT NULL,
    concept_name varchar(255) NOT NULL,
    domain_id varchar(20) NOT NULL,
    vocabulary_id varchar(20) NOT NULL,
    concept_class_id varchar(20) NOT NULL,
    standard_concept varchar(1) NULL,
    concept_code varchar(50) NOT NULL,
    valid_start_date date NOT NULL,
    valid_end_date date NOT NULL,
    invalid_reason varchar(1) NULL 

) ON [fg_user1];

--HINT DISTRIBUTE ON RANDOM
 CREATE TABLE xref.VOCABULARY (

    vocabulary_id varchar(20) NOT NULL,
    vocabulary_name varchar(255) NOT NULL,
    vocabulary_reference varchar(255) NOT NULL,
    vocabulary_version varchar(255) NULL,
    vocabulary_concept_id integer NOT NULL 

) ON [fg_user1];

--HINT DISTRIBUTE ON RANDOM
 CREATE TABLE xref.DOMAIN (

    domain_id varchar(20) NOT NULL,
    domain_name varchar(255) NOT NULL,
    domain_concept_id integer NOT NULL 

) ON [fg_user1];

--HINT DISTRIBUTE ON RANDOM
 CREATE TABLE xref.CONCEPT_CLASS (

    concept_class_id varchar(20) NOT NULL,
    concept_class_name varchar(255) NOT NULL,
    concept_class_concept_id integer NOT NULL 

) ON [fg_user1];

--HINT DISTRIBUTE ON RANDOM
 CREATE TABLE xref.CONCEPT_RELATIONSHIP (

    concept_id_1 integer NOT NULL,
    concept_id_2 integer NOT NULL,
    relationship_id varchar(20) NOT NULL,
    valid_start_date date NOT NULL,
    valid_end_date date NOT NULL,
    invalid_reason varchar(1) NULL 
    
) ON [fg_user1];

--HINT DISTRIBUTE ON RANDOM
 CREATE TABLE xref.RELATIONSHIP (

    relationship_id varchar(20) NOT NULL,
    relationship_name varchar(255) NOT NULL,
    is_hierarchical varchar(1) NOT NULL,
    defines_ancestry varchar(1) NOT NULL,
    reverse_relationship_id varchar(20) NOT NULL,
    relationship_concept_id integer NOT NULL 

) ON [fg_user1];

--HINT DISTRIBUTE ON RANDOM
 CREATE TABLE xref.CONCEPT_SYNONYM (

    concept_id integer NOT NULL,
    concept_synonym_name varchar(1000) NOT NULL,
    language_concept_id integer NOT NULL 

) ON [fg_user1];

--HINT DISTRIBUTE ON RANDOM
 CREATE TABLE xref.CONCEPT_ANCESTOR (

    ancestor_concept_id integer NOT NULL,
    descendant_concept_id integer NOT NULL,
    min_levels_of_separation integer NOT NULL,
    max_levels_of_separation integer NOT NULL 

) ON [fg_user1];

--HINT DISTRIBUTE ON RANDOM
 CREATE TABLE xref.SOURCE_TO_CONCEPT_MAP (

    source_code varchar(50) NOT NULL,
    source_concept_id integer NOT NULL,
    source_vocabulary_id varchar(20) NOT NULL,
    source_code_description varchar(255) NULL,
    target_concept_id integer NOT NULL,
    target_vocabulary_id varchar(20) NOT NULL,
    valid_start_date date NOT NULL,
    valid_end_date date NOT NULL,
    invalid_reason varchar(1) NULL 

) ON [fg_user1];

--HINT DISTRIBUTE ON RANDOM
 CREATE TABLE xref.DRUG_STRENGTH (

    drug_concept_id integer NOT NULL,
    ingredient_concept_id integer NOT NULL,
    amount_value float NULL,
    amount_unit_concept_id integer NULL,
    numerator_value float NULL,
    numerator_unit_concept_id integer NULL,
    denominator_value float NULL,
    denominator_unit_concept_id integer NULL,
    box_size integer NULL,
    valid_start_date date NOT NULL,
    valid_end_date date NOT NULL,
    invalid_reason varchar(1) NULL 

) ON [fg_user1];
