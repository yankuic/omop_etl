insert into preload.measurement with (tablock)
select distinct 
       person_id = b.person_id
      ,measurement_concept_id = isnull(d.target_concept_id,0)
      ,measurement_date = a.Respiratory_Date
      ,measurement_datetime = a.Respiratory_Datetime
      ,measurement_time = cast(a.Respiratory_Datetime as TIME)
      ,measurement_type_concept_id = 32817
      ,operator_concept_id = NULL
      ,value_as_number = a.PIP
      ,value_as_concept_id = NULL
      ,unit_concept_id = 0
      ,range_low = NULL
      ,range_high = NULL
      ,provider_id = c.provider_id
      ,visit_occurrence_id = e.visit_occurrence_id
      ,visit_detail_id = NULL
      ,measurement_source_value = d.source_code
      ,measurement_source_concept_id = isnull(d.source_concept_id,0)
      ,unit_source_value = 'cmH2O'
      ,value_source_value = a.PIP
      ,source_table = 'measurement_res_pip'
from stage.measurement_res_pip a 
join xref.person_mapping b
on a.patient_key = b.patient_key
left join xref.provider c 
on c.provider_source_value = isnull(a.Attending_Provider, a.Visit_Provider)
left join xref.source_to_concept_map d 
on source_code = 'PIP' and source_vocabulary_id = 'Flowsheet'
left join xref.visit_occurrence_mapping e 
on a.patnt_encntr_key = e.patnt_encntr_key
