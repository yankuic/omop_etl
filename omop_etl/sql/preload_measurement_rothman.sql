insert into preload.measurement with (tablock)
select distinct 
       person_id = b.person_id
      ,measurement_concept_id = d.target_concept_id
      ,measurement_date = a.Rothman_Index_Date
      ,measurement_datetime = a.Rothman_Index_Datetime
      ,measurement_time = CAST(a.Rothman_Index_Datetime as TIME)
      ,measurement_type_concept_id = 32817
      ,operator_concept_id = NULL
      ,value_as_number = a.Rothman_Index_Score
      ,value_as_concept_id = NULL
      ,unit_concept_id = 0
      ,range_low = NULL
      ,range_high = NULL
      ,provider_id = c.provider_id
      ,visit_occurrence_id = e.visit_occurrence_id
      ,visit_detail_id = NULL
      ,measurement_source_value = d.source_code
      ,measurement_source_concept_id = d.source_concept_id
      ,unit_source_value = '{score}'
      ,value_source_value = a.Rothman_Index_Score
      ,source_table = 'measurement_rothman'
from stage.measurement_rothman a 
join xref.person_mapping b
on a.patient_key = b.patient_key
left join xref.provider_mapping c 
on c.providr_key = isnull(a.Attending_Provider, a.Visit_Provider)
left join xref.source_to_concept_map d 
on source_code = 'ROTHMAN SCORE' and source_vocabulary_id = 'Flowsheet'
left join xref.visit_occurrence_mapping e 
on a.patnt_encntr_key = e.patnt_encntr_key
where b.active_ind = 'Y'
