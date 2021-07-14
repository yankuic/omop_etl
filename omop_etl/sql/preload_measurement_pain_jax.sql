
;with painscale as (
  SELECT [patient_key]
        ,[patnt_encntr_key]
        ,[pain_date]
        ,[pain_datetime]
        ,[provider] = isnull([attending_provider],[visit_provider])
        ,pain_scale = 'PAIN SCALE'
        ,pain_score = pain_jax
    FROM [DWS_OMOP].[stage].[MEASUREMENT_PainScale_JAX]
) 
insert into preload.measurement with (tablock)
select person_id = b.person_id
    ,measurement_concept_id = isnull(d.target_concept_id, 0)
    ,measurement_date = a.PAIN_DATE
    ,measurement_datetime = a.PAIN_DATETIME
    ,measurement_time = CAST(a.PAIN_DATETIME as TIME)
    ,measurement_type_concept_id = 32817
    ,operator_concept_id = NULL
    ,value_as_number = try_convert(float, a.pain_score)
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
    ,value_source_value = a.pain_score
    ,source_table = 'measurement_painscale_jax'
from painscale a 
join xref.person_mapping b
on a.patient_key = b.patient_key
left join xref.provider_mapping c 
on c.providr_key = a.provider
left join xref.source_to_concept_map d 
on source_code = a.pain_scale and source_vocabulary_id = 'Flowsheet'
left join xref.visit_occurrence_mapping e 
on a.patnt_encntr_key = e.patnt_encntr_key
where b.active_ind = 'Y'

drop table if exists #measurement_painscale
