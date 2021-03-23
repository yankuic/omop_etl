USE DWS_OMOP

drop table if exists [xref].[person_mapping]
CREATE TABLE [xref].[person_mapping](
	[person_id] [int] IDENTITY(1,1) NOT NULL,
	[patient_key] [int] NULL,
	[date_shift][int] NULL,
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


drop table if exists [xref].[visit_occurrence_mapping]
create table [xref].[visit_occurrence_mapping](
	[visit_occurrence_id] [int] identity(1,1) not null,
	[patnt_encntr_key] [decimal](18, 0) null,
	[load_dt] [datetime2](7) null,
	[active_ind] [varchar](1) null,
 constraint [xpk_visit_occurrence_mapping] primary key clustered 
(
	[visit_occurrence_id] asc
)with (pad_index = off, 
	   statistics_norecompute = off, 
	   ignore_dup_key = off, 
	   allow_row_locks = on, 
	   allow_page_locks = on
	) on [fg_user1]
) on [fg_user1]
