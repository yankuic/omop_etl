drop index if exists
      [ix_procedureconceptid_personid] ON [dbo].[procedure_occurrence],
      [ix_personid_procedureconceptid] ON [dbo].[procedure_occurrence]

alter table [dbo].[procedure_occurrence] 
drop constraint if exists [pk_procedure_occurrence]

insert into dbo.procedure_occurrence with (tablock) (
    [person_id]
    ,[procedure_concept_id]
    ,[procedure_date]
    ,[procedure_datetime]
    ,[procedure_type_concept_id]
    ,[modifier_concept_id]
    ,[quantity]
    ,[provider_id]
    ,[visit_occurrence_id]
    ,[visit_detail_id]
    ,[procedure_source_value]
    ,[procedure_source_concept_id]
    ,[modifier_source_value]
)
select person_id
    ,[procedure_concept_id]
    ,[procedure_date]
    ,[procedure_datetime]
    ,[procedure_type_concept_id]
    ,[modifier_concept_id]
    ,[quantity]
    ,[provider_id]
    ,[visit_occurrence_id]
    ,[visit_detail_id]
    ,[procedure_source_value]
    ,[procedure_source_concept_id]
    ,[modifier_source_value]
from preload.procedure_occurrence

create nonclustered index [ix_procedureconceptid_personid] 
on [dbo].[procedure_occurrence]
(
	[procedure_concept_id] ASC,
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

create nonclustered index [ix_personid_procedureconceptid] 
on [dbo].[procedure_occurrence]
(
	[person_id] ASC,
	[procedure_concept_id] ASC
)with (PAD_INDEX = OFF
      ,STATISTICS_NORECOMPUTE = OFF
      ,SORT_IN_TEMPDB = OFF
      ,DROP_EXISTING = OFF
      ,ONLINE = OFF
      ,ALLOW_ROW_LOCKS = ON
      ,ALLOW_PAGE_LOCKS = ON
      ,OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF
) ON [fg_user1]

alter table [dbo].[procedure_occurrence] 
add constraint [pk_procedure_occurrence] PRIMARY KEY CLUSTERED 
(
	[procedure_occurrence_id] ASC,
	[person_id] ASC,
	[procedure_concept_id] ASC
)with (PAD_INDEX = OFF
      ,STATISTICS_NORECOMPUTE = OFF
      ,SORT_IN_TEMPDB = OFF
      ,IGNORE_DUP_KEY = OFF
      ,ONLINE = OFF
      ,ALLOW_ROW_LOCKS = ON
      ,ALLOW_PAGE_LOCKS = ON
      ,OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF
) ON [fg_user1]
