insert into preload.measurement with (tablock)
select distinct 
       person_id = b.person_id
      ,measurement_concept_id = isnull(d.target_concept_id,0)
      ,measurement_date = a.VITALS_DATE
      ,measurement_datetime = a.VITALS_DATETIME
      ,measurement_time = CAST(a.VITALS_DATETIME as TIME)
      ,measurement_type_concept_id = 32817
      ,operator_concept_id = NULL
      ,value_as_number = a.HEARTRATE
      ,value_as_concept_id = NULL
      ,unit_concept_id = 8483
      ,range_low = NULL
      ,range_high = NULL
      ,provider_id = c.provider_id
      ,visit_occurrence_id = e.visit_occurrence_id
      ,visit_detail_id = NULL
      ,measurement_source_value = d.source_code
      ,measurement_source_concept_id = isnull(d.source_concept_id,0)
      ,unit_source_value = 'BEATS P/M'
      ,value_source_value = a.HEARTRATE
      ,source_table = 'measurement_heartrate'
from stage.measurement_heartrate a 
join xref.person_mapping b
on a.patient_key = b.patient_key
left join xref.provider_mapping c 
on c.providr_key = isnull(a.Attending_Provider, a.Visit_Provider)
left join xref.source_to_concept_map d 
on source_code = 'HEART RATE' and source_vocabulary_id = 'Flowsheet'
left join xref.visit_occurrence_mapping e 
on a.patnt_encntr_key = e.patnt_encntr_key
