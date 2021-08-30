drop index if exists
      [ix_observationconceptid_personid] ON [dbo].[observation],
      [ix_personid_observationconceptid] ON [dbo].[observation]

alter table [dbo].[observation] 
drop constraint if exists [pk_observation]

insert into dbo.observation with (tablock) (
    [person_id]
    ,[observation_concept_id]
    ,[observation_date]
    ,[observation_datetime]
    ,[observation_type_concept_id]
    ,[value_as_number]
    ,[value_as_string]
    ,[value_as_concept_id]
    ,[qualifier_concept_id]
    ,[unit_concept_id]
    ,[provider_id]
    ,[visit_occurrence_id]
    ,[visit_detail_id]
    ,[observation_source_value]
    ,[observation_source_concept_id]
    ,[unit_source_value]
    ,[qualifier_source_value]
)
select person_id
      ,[observation_concept_id]
      ,[observation_date]
      ,[observation_datetime]
      ,[observation_type_concept_id]
      ,[value_as_number]
      ,[value_as_string]
      ,[value_as_concept_id]
      ,[qualifier_concept_id]
      ,[unit_concept_id]
      ,[provider_id]
      ,[visit_occurrence_id]
      ,[visit_detail_id]
      ,[observation_source_value]
      ,[observation_source_concept_id]
      ,[unit_source_value]
      ,[qualifier_source_value]
from preload.observation  

create nonclustered index [ix_observationconceptid_personid] 
on [dbo].[observation]
(
	[observation_concept_id] ASC,
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

create nonclustered index [ix_personid_observationconceptid] 
on [dbo].[observation]
(
	[person_id] ASC,
	[observation_concept_id] ASC
)with (PAD_INDEX = OFF
      ,STATISTICS_NORECOMPUTE = OFF
      ,SORT_IN_TEMPDB = OFF
      ,DROP_EXISTING = OFF
      ,ONLINE = OFF
      ,ALLOW_ROW_LOCKS = ON
      ,ALLOW_PAGE_LOCKS = ON
      ,OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF
) ON [fg_user1]

alter table [dbo].[observation] 
add constraint [pk_observation] PRIMARY KEY CLUSTERED 
(
	[observation_id] ASC,
	[person_id] ASC,
	[observation_concept_id] ASC
)with (PAD_INDEX = OFF
      ,STATISTICS_NORECOMPUTE = OFF
      ,SORT_IN_TEMPDB = OFF
      ,IGNORE_DUP_KEY = OFF
      ,ONLINE = OFF
      ,ALLOW_ROW_LOCKS = ON
      ,ALLOW_PAGE_LOCKS = ON
      ,OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF
) ON [fg_user1]
