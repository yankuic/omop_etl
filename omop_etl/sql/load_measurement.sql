drop index if exists
      [ix_measurementconceptid_personid] ON [dbo].[measurement],
      [ix_personid_measurementconceptid] ON [dbo].[measurement]

alter table [dbo].[measurement] 
drop constraint if exists [pk_measurement]

insert into dbo.measurement with (tablock) (
     person_id
    ,measurement_concept_id
    ,measurement_date
    ,measurement_datetime
    ,measurement_time
    ,measurement_type_concept_id
    ,operator_concept_id
    ,value_as_number
    ,value_as_concept_id
    ,unit_concept_id
    ,range_low
    ,range_high
    ,provider_id
    ,visit_occurrence_id
    ,visit_detail_id
    ,measurement_source_value
    ,measurement_source_concept_id
    ,unit_source_value
    ,value_source_value
)
select distinct person_id
    ,measurement_concept_id
    ,measurement_date
    ,measurement_datetime
    ,measurement_time
    ,measurement_type_concept_id
    ,operator_concept_id
    ,value_as_number
    ,value_as_concept_id
    ,unit_concept_id
    ,range_low
    ,range_high
    ,provider_id
    ,visit_occurrence_id
    ,visit_detail_id
    ,measurement_source_value
    ,measurement_source_concept_id
    ,unit_source_value
    ,value_source_value
from preload.measurement

create nonclustered index [ix_measurementconceptid_personid] 
on [dbo].[measurement]
(
	[measurement_concept_id] ASC,
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

create nonclustered index [ix_personid_measurementconceptid] 
on [dbo].[measurement]
(
	[person_id] ASC,
	[measurement_concept_id] ASC
)with (PAD_INDEX = OFF
      ,STATISTICS_NORECOMPUTE = OFF
      ,SORT_IN_TEMPDB = OFF
      ,DROP_EXISTING = OFF
      ,ONLINE = OFF
      ,ALLOW_ROW_LOCKS = ON
      ,ALLOW_PAGE_LOCKS = ON
      ,OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF
) ON [fg_user1]

alter table [dbo].[measurement] 
add constraint [pk_measurement] PRIMARY KEY CLUSTERED 
(
	[measurement_id] ASC,
	[person_id] ASC,
	[measurement_concept_id] ASC
)with (PAD_INDEX = OFF
      ,STATISTICS_NORECOMPUTE = OFF
      ,SORT_IN_TEMPDB = OFF
      ,IGNORE_DUP_KEY = OFF
      ,ONLINE = OFF
      ,ALLOW_ROW_LOCKS = ON
      ,ALLOW_PAGE_LOCKS = ON
      ,OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF
) ON [fg_user1]
