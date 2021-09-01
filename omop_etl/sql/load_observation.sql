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

