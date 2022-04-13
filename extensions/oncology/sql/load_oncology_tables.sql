/*
Load tables from the Oncology Extension into hipaa schema
These tables are not included in a typical omop_etl release
*/

--Load with deidentified datetime.
drop table if exists hipaa.episode
select episode_id
      ,a.person_id
      ,episode_concept_id
      ,episode_start_datetime = dateadd(day, b.date_shift, a.episode_start_datetime)
      ,episode_end_datetime = dateadd(day, b.date_shift, a.episode_end_datetime)
      ,episode_parent_id
      ,episode_number
      ,episode_object_concept_id
      ,episode_type_concept_id
      ,episode_source_value
      ,episode_source_concept_id
into hipaa.episode
from dbo.episode a
join xref.person_mapping b
on a.person_id = b.person_id
where b.active_ind = 'Y'

drop table if exists hipaa.episode_event 
select [episode_id]
      ,[event_id]
      ,[episode_event_field_concept_id]
into hipaa.episode_event
from dbo.episode_event

drop table if exists hipaa.fact_relationship 
select [domain_concept_id_1]
      ,[fact_id_1]
      ,[domain_concept_id_2]
      ,[fact_id_2]
      ,[relationship_concept_id]
into hipaa.fact_relationship
from dbo.fact_relationship 

drop table if exists hipaa.metadata 
select [metadata_concept_id]
      ,[metadata_type_concept_id]
      ,[name]
      ,[value_as_string]
      ,[value_as_concept_id]
      ,[metadata_date] 
      ,[metadata_datetime]
into hipaa.metadata
from dbo.metadata 
