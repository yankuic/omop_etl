--bypass truncation warnings
-- SET ANSI_WARNINGS OFF

insert into preload.measurement with (tablock)
select distinct 
       person_id = b.person_id
      ,measurement_concept_id = d.target_concept_id
      ,measurement_date = a.Respiratory_Date
      ,measurement_datetime = a.Respiratory_Datetime
      ,measurement_time = CAST(a.Respiratory_Datetime as TIME)
      ,measurement_type_concept_id = 32817
      ,operator_concept_id = NULL
      ,value_as_number = NULL
      ,value_as_concept_id = NULL
      ,unit_concept_id = NULL
      ,range_low = NULL
      ,range_high = NULL
      ,provider_id = c.provider_id
      ,visit_occurrence_id = e.visit_occurrence_id
      ,visit_detail_id = NULL
      ,measurement_source_value = d.source_code
      ,measurement_source_concept_id = d.source_concept_id
      ,unit_source_value = NULL
      --explicit truncation to avoid truncation warning
      ,value_source_value = left(a.Respiratory_Device,50)
      ,source_table = 'measurement_res_device'
from stage.measurement_res_device a 
join xref.person_mapping b
on a.patient_key = b.patient_key
left join xref.provider c 
on c.provider_source_value = isnull(a.Attending_Provider, a.Visit_Provider)
left join xref.source_to_concept_map d 
on source_code = 'RESP DEVICE' and source_vocabulary_id = 'Flowsheet'
left join xref.visit_occurrence_mapping e 
on a.patnt_encntr_key = e.patnt_encntr_key

-- SET ANSI_WARNINGS ON
