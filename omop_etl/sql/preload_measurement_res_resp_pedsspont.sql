insert into preload.measurement with (tablock)
select person_id = b.person_id
    ,measurement_concept_id = isnull(d.target_concept_id,0)
    ,measurement_date = a.Respiratory_Date
    ,measurement_datetime = a.Respiratory_Datetime
    ,measurement_time = CAST(a.Respiratory_Datetime as TIME)
    ,measurement_type_concept_id = 32817
    ,operator_concept_id = NULL
    ,value_as_number = try_convert(float, a.Peds_Spont_Resp_Rate)
    ,value_as_concept_id = NULL
    ,unit_concept_id = 0
    ,range_low = NULL
    ,range_high = NULL
    ,provider_id = c.provider_id
    ,visit_occurrence_id = e.visit_occurrence_id
    ,visit_detail_id = NULL
    ,measurement_source_value = d.source_code
    ,measurement_source_concept_id = isnull(d.source_concept_id,0)
    ,unit_source_value = 'BREATHS P/M'
    ,value_source_value = a.Peds_Spont_Resp_Rate
    ,source_table = 'measurement_res_resp_pedsspont'
from stage.measurement_res_resp_pedsspont a 
join xref.person_mapping b
on a.patient_key = b.patient_key
left join xref.provider_mapping c 
on c.providr_key = isnull(a.Attending_Provider, a.Visit_Provider)
left join xref.source_to_concept_map d 
on source_code = 'RESP RATE - Peds Spont' and source_vocabulary_id = 'Flowsheet'
left join xref.visit_occurrence_mapping e 
on a.patnt_encntr_key = e.patnt_encntr_key
where a.Peds_Spont_Resp_Rate is not NULL
and b.active_ind = 'Y'
