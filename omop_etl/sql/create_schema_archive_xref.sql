IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'archive_xref')
BEGIN
	EXEC( 'CREATE SCHEMA archive_xref' );
END

--- MAPPING TABLES ---
CREATE TABLE [archive_xref].[PERSON_MAPPING](
	
    [person_id] [int] NOT NULL,
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

CREATE TABLE [archive_xref].[VISIT_OCCURRENCE_MAPPING](

	[visit_occurrence_id] [int] NOT NULL,
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

CREATE TABLE [archive_xref].[CARE_SITE_MAPPING](

	[care_site_id] [int] NOT NULL,
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

CREATE TABLE [archive_xref].[LOCATION_MAPPING](

	[location_id] [int] NOT NULL,
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


CREATE TABLE [archive_xref].[PROVIDER_MAPPING](

	[provider_id] [int] NOT NULL,
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
