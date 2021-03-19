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
select a.person_id
    ,measurement_concept_id
    ,measurement_date = dateadd(day, @DateShift, a.measurement_date)
    ,measurement_datetime = dateadd(day, @DateShift, a.measurement_datetime)
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
from preload.measurement a 
join xref.person_mapping b 
on a.person_id = b.person_id 
