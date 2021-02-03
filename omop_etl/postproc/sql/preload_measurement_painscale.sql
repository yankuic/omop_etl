insert into preload.measurement with (tablock)
select distinct *
from (
    select person_id = b.person_id
        ,measurement_concept_id = isnull(d.target_concept_id, 0)
        ,measurement_date = a.PAIN_DATE
        ,measurement_datetime = a.PAIN_DATETIME
        ,measurement_time = CAST(a.PAIN_DATETIME as TIME)
        ,measurement_type_concept_id = 32817
        ,operator_concept_id = NULL
        ,value_as_number = a.Pain_Peds_Wong_Baker
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
        ,value_source_value = a.Pain_Peds_Wong_Baker
        ,source_table = 'measurement_painscale'
    from stage.measurement_painscale a 
    join xref.person_mapping b
    on a.patient_key = b.patient_key
    join xref.provider c 
    on c.provider_source_value = isnull(a.Attending_Provider, a.Visit_Provider)
    left join xref.source_to_concept_map d 
    on source_code = 'PAIN SCALE - Peds Wong-Baker' and source_vocabulary_id = 'Flowsheet'
    join xref.visit_occurrence_mapping e 
    on a.patnt_encntr_key = e.patnt_encntr_key

    union
    select person_id = b.person_id
        ,measurement_concept_id = isnull(d.target_concept_id, 0)
        ,measurement_date = a.PAIN_DATE
        ,measurement_datetime = a.PAIN_DATETIME
        ,measurement_time = CAST(a.PAIN_DATETIME as TIME)
        ,measurement_type_concept_id = 32817
        ,operator_concept_id = NULL
        ,value_as_number = a.PAIN_UF_DVPRS
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
        ,value_source_value = a.Pain_Peds_Wong_Baker
        ,source_table = 'measurement_painscale'
    from stage.measurement_painscale a 
    join xref.person_mapping b
    on a.patient_key = b.patient_key
    join xref.provider c 
    on c.provider_source_value = isnull(a.Attending_Provider, a.Visit_Provider)
    left join xref.source_to_concept_map d 
    on source_code = 'PAIN SCALE - UF DVPRS' and source_vocabulary_id = 'Flowsheet'
    join xref.visit_occurrence_mapping e 
    on a.patnt_encntr_key = e.patnt_encntr_key

    union
    select person_id = b.person_id
        ,measurement_concept_id = isnull(d.target_concept_id, 0)
        ,measurement_date = a.PAIN_DATE
        ,measurement_datetime = a.PAIN_DATETIME
        ,measurement_time = CAST(a.PAIN_DATETIME as TIME)
        ,measurement_type_concept_id = 32817
        ,operator_concept_id = NULL
        ,value_as_number = a.Pain_JAX
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
        ,value_source_value = a.Pain_Peds_Wong_Baker
        ,source_table = 'measurement_painscale'
    from stage.measurement_painscale a 
    join xref.person_mapping b
    on a.patient_key = b.patient_key
    join xref.provider c 
    on c.provider_source_value = isnull(a.Attending_Provider, a.Visit_Provider)
    left join xref.source_to_concept_map d 
    on source_code = 'PAIN SCALE - Jax' and source_vocabulary_id = 'Flowsheet'
    join xref.visit_occurrence_mapping e 
    on a.patnt_encntr_key = e.patnt_encntr_key
) x
where value_as_number is not null 
