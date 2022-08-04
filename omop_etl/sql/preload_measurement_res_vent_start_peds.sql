insert into preload.measurement with (tablock)
select person_id = b.person_id
    ,measurement_concept_id = isnull(d.target_concept_id,0)
    ,measurement_date = a.Respiratory_Date
    ,measurement_datetime = a.Respiratory_Datetime
    ,measurement_time = cast(a.Respiratory_Datetime as TIME)
    ,measurement_type_concept_id = 32817
    ,operator_concept_id = NULL
    ,value_as_number = NULL 
    ,value_as_concept_id = NULL
    ,unit_concept_id = NULL
    ,range_low = NULL
    ,range_high = NULL
    ,provider_id = c.provider_id
    ,visit_occurrence_id = isnull(f.visit_occurrence_id,e.visit_occurrence_id)
    ,visit_detail_id = f.visit_detail_id
    ,measurement_source_value = d.source_code
    ,measurement_source_concept_id = isnull(d.source_concept_id, 0)
    ,unit_source_value = NULL
    ,value_source_value = a.respiratory_vent_bgn
    ,source_table = 'measurement_res_vent_start_peds'
from stage.MEASUREMENT_Res_Vent_Start_Peds a  
join xref.person_mapping b
on a.patient_key = b.patient_key
left join xref.provider_mapping c 
on c.providr_key = isnull(a.Attending_Provider, a.Visit_Provider) and c.providr_key > 0
left join xref.source_to_concept_map d 
on source_code = 'VENT START - Peds' and source_vocabulary_id = 'Flowsheet'
left join xref.visit_occurrence_mapping e 
on a.patnt_encntr_key = e.patnt_encntr_key
left join xref.visit_detail_mapping f
on a.patnt_encntr_key = f.patnt_encntr_key
where b.active_ind = 'Y'
