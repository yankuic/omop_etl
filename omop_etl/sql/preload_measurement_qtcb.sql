insert into preload.measurement with (tablock)
select distinct 
       person_id = b.person_id
      ,measurement_concept_id = isnull(d.target_concept_id,0)
      ,measurement_date = a.ECG_Acq_Date
      ,measurement_datetime = CAST([ECG_Acq_Date] as datetime) + CAST(LEFT([ECG_Acq_Time], 2) + ':' + RIGHT([ECG_Acq_Time],2) as datetime)
      ,measurement_time = CAST(LEFT([ECG_Acq_Time], 2) + ':' + RIGHT([ECG_Acq_Time],2) AS TIME)
      ,measurement_type_concept_id = 32817
      ,operator_concept_id = NULL
      ,value_as_number = a.QTCB
      ,value_as_concept_id = NULL
      ,unit_concept_id = 9593
      ,range_low = NULL
      ,range_high = NULL
      ,provider_id = c.provider_id
      ,visit_occurrence_id = isnull(f.visit_occurrence_id,e.visit_occurrence_id)
      ,visit_detail_id = f.visit_detail_id
      ,measurement_source_value = d.source_code
      ,measurement_source_concept_id = isnull(d.source_concept_id,0)
      ,unit_source_value = 'ms'
      ,value_source_value = a.QTCB
      ,source_table = 'measurement_qtcb'
from stage.measurement_qtcb a 
join xref.person_mapping b
on a.patient_key = b.patient_key
left join xref.provider_mapping c 
on c.providr_key = isnull(a.Attending_Provider, a.Visit_Provider) and c.providr_key > 0
left join xref.source_to_concept_map d 
on source_code = 'QTCB' and source_vocabulary_id = 'Flowsheet'
left join xref.visit_occurrence_mapping e 
on a.patnt_encntr_key = e.patnt_encntr_key
left join xref.visit_detail_mapping f
on a.patnt_encntr_key = f.patnt_encntr_key
where b.active_ind = 'Y'
