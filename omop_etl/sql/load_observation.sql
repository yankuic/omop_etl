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
select a.person_id
      ,[observation_concept_id]
      ,[observation_date]
      ,[observation_datetime]
      ,[observation_type_concept_id]
      ,[value_as_number]
      ,[value_as_string]
      ,[value_as_concept_id]
      ,[qualifier_concept_id]
      ,[unit_concept_id]
      ,a.provider_id
      ,[visit_occurrence_id]
      ,[visit_detail_id]
      ,[observation_source_value]
      ,[observation_source_concept_id]
      ,[unit_source_value]
      ,[qualifier_source_value]
from preload.observation a
-- join dbo.person b
-- on a.person_id = b.person_id
-- where visit_occurrence_id is null 
-- or visit_occurrence_id in (
--       select visit_occurrence_id 
--       from dbo.visit_occurrence
-- )
