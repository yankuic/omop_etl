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
select distinct 
    a.person_id
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
    ,a.provider_id
    ,visit_occurrence_id
    ,visit_detail_id
    ,measurement_source_value
    ,measurement_source_concept_id
    ,unit_source_value
    ,value_source_value
from preload.measurement a
join dbo.person b
on a.person_id = b.person_id
where visit_occurrence_id is null 
or visit_occurrence_id in (
      select visit_occurrence_id 
      from dbo.visit_occurrence
)
