insert into preload.measurement with (tablock)
select distinct 
      person_id = b.person_id
      ,measurement_concept_id = d.target_concept_id
      ,measurement_date = a.HEIGHT_DATE
      ,measurement_datetime = a.HEIGHT_DATETIME
      ,measurement_time = CAST(a.HEIGHT_DATETIME as TIME)
      ,measurement_type_concept_id = 32817
      ,operator_concept_id = NULL
      ,value_as_number = a.HEIGHT_CM
      ,value_as_concept_id = NULL
      ,unit_concept_id = 8582
      ,range_low = NULL
      ,range_high = NULL
      ,provider_id = c.provider_id
      ,visit_occurrence_id = e.visit_occurrence_id
      ,visit_detail_id = NULL
      ,measurement_source_value = d.source_code
      ,measurement_source_concept_id = d.source_concept_id
      ,unit_source_value = NULL
      ,value_source_value = 'BP-SYSTOLIC'
      ,source_table = 'measurement_height'
from stage.measurement_height a 
join xref.person_mapping b
on a.patient_key = b.patient_key
join xref.provider c 
on c.provider_source_value = isnull(a.Attending_Provider, a.Visit_Provider)
left join xref.source_to_concept_map d 
on source_code = 'height' and source_vocabulary_id = 'Flowsheet'
join xref.visit_occurrence_mapping e 
on a.patnt_encntr_key = e.patnt_encntr_key
