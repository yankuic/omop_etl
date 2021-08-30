drop index if exists
      [ix_conditionconceptid_personid] ON [dbo].[condition_occurrence],
      [ix_personid_conditionconceptid] ON [dbo].[condition_occurrence]

alter table [dbo].[condition_occurrence] 
drop constraint if exists [pk_condition_occurrence]

insert into dbo.condition_occurrence with (tablock) (
       [person_id]
      ,[condition_concept_id]
      ,[condition_start_date]
      ,[condition_start_datetime]
      ,[condition_end_date]
      ,[condition_end_datetime]
      ,[condition_type_concept_id]
      ,[stop_reason]
      ,[provider_id]
      ,[visit_occurrence_id]
      ,[visit_detail_id]
      ,[condition_source_value]
      ,[condition_source_concept_id]
      ,[condition_status_source_value]
      ,[condition_status_concept_id]
)
select person_id
      ,[condition_concept_id]
      ,condition_start_date 
      ,condition_start_datetime
      ,condition_end_date 
      ,condition_end_datetime
      ,[condition_type_concept_id]
      ,[stop_reason]
      ,[provider_id]
      ,[visit_occurrence_id]
      ,[visit_detail_id]
      ,[condition_source_value]
      ,[condition_source_concept_id]
      ,[condition_status_source_value]
      ,[condition_status_concept_id]
from [preload].[condition_occurrence] 

create nonclustered index [ix_conditionconceptid_personid] 
on [dbo].[condition_occurrence]
(
	[condition_concept_id] ASC,
	[person_id] ASC
) with (PAD_INDEX = OFF
       ,STATISTICS_NORECOMPUTE = OFF
       ,SORT_IN_TEMPDB = OFF
       ,DROP_EXISTING = OFF
       ,ONLINE = OFF
       ,ALLOW_ROW_LOCKS = ON
       ,ALLOW_PAGE_LOCKS = ON
       ,OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF
) ON [fg_user1]

create nonclustered index [ix_personid_conditionconceptid] 
on [dbo].[condition_occurrence]
(
	[person_id] ASC,
	[condition_concept_id] ASC
)with (PAD_INDEX = OFF
      ,STATISTICS_NORECOMPUTE = OFF
      ,SORT_IN_TEMPDB = OFF
      ,DROP_EXISTING = OFF
      ,ONLINE = OFF
      ,ALLOW_ROW_LOCKS = ON
      ,ALLOW_PAGE_LOCKS = ON
      ,OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF
) ON [fg_user1]

alter table [dbo].[condition_occurrence] 
add constraint [pk_condition_occurrence] PRIMARY KEY CLUSTERED 
(
	[condition_occurrence_id] ASC,
	[person_id] ASC,
	[condition_concept_id] ASC
)with (PAD_INDEX = OFF
      ,STATISTICS_NORECOMPUTE = OFF
      ,SORT_IN_TEMPDB = OFF
      ,IGNORE_DUP_KEY = OFF
      ,ONLINE = OFF
      ,ALLOW_ROW_LOCKS = ON
      ,ALLOW_PAGE_LOCKS = ON
      ,OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF
) ON [fg_user1]
