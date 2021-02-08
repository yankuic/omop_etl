insert into preload.measurement with (tablock)
select distinct *
from (
    select person_id = b.person_id
        ,measurement_concept_id = d.target_concept_id
        ,measurement_date = a.Respiratory_Date
        ,measurement_datetime = a.Respiratory_Datetime
        ,measurement_time = CAST(a.Respiratory_Datetime as TIME)
        ,measurement_type_concept_id = 32817
        ,operator_concept_id = NULL
        ,value_as_number = a.O2_Lmin
        ,value_as_concept_id = NULL
        ,unit_concept_id = 8698
        ,range_low = NULL
        ,range_high = NULL
        ,provider_id = c.provider_id
        ,visit_occurrence_id = e.visit_occurrence_id
        ,visit_detail_id = NULL
        ,measurement_source_value = d.source_code
        ,measurement_source_concept_id = d.source_concept_id
        ,unit_source_value = 'L/min'
        ,value_source_value = a.O2_Lmin
        ,source_table = 'measurement_res_o2'
    from stage.measurement_res_o2 a 
    join xref.person_mapping b
    on a.patient_key = b.patient_key
    join xref.provider c 
    on c.provider_source_value = isnull(a.Attending_Provider, a.Visit_Provider)
    left join xref.source_to_concept_map d 
    on source_code = 'O2 FLOW RATE - L/MIN' and source_vocabulary_id = 'Flowsheet'
    join xref.visit_occurrence_mapping e 
    on a.patnt_encntr_key = e.patnt_encntr_key

    union 
    select person_id = b.person_id
        ,measurement_concept_id = d.target_concept_id
        ,measurement_date = a.Respiratory_Date
        ,measurement_datetime = a.Respiratory_Datetime
        ,measurement_time = CAST(a.Respiratory_Datetime as TIME)
        ,measurement_type_concept_id = 32817
        ,operator_concept_id = NULL
        ,value_as_number = a.O2_mLmin
        ,value_as_concept_id = NULL
        ,unit_concept_id = 8795
        ,range_low = NULL
        ,range_high = NULL
        ,provider_id = c.provider_id
        ,visit_occurrence_id = e.visit_occurrence_id
        ,visit_detail_id = NULL
        ,measurement_source_value = d.source_code
        ,measurement_source_concept_id = d.source_concept_id
        ,unit_source_value = 'mL/min'
        ,value_source_value = a.O2_mLmin
        ,source_table = 'measurement_res_o2'
    from stage.measurement_res_o2 a 
    join xref.person_mapping b
    on a.patient_key = b.patient_key
    join xref.provider c 
    on c.provider_source_value = isnull(a.Attending_Provider, a.Visit_Provider)
    left join xref.source_to_concept_map d 
    on source_code = 'O2 FLOW RATE - mL/MIN' and source_vocabulary_id = 'Flowsheet'
    join xref.visit_occurrence_mapping e 
    on a.patnt_encntr_key = e.patnt_encntr_key
) x
where value_source_value is not null 
