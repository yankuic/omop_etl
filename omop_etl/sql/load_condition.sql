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
