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

