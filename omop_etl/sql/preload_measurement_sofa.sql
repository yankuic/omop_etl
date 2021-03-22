SET NOCOUNT ON;

drop table if exists #measurement_sofa
select patient_key
    ,patnt_encntr_key
    ,date_of_care
    ,provider = isnull(Attending_Provider,Visit_Provider)
    ,score 
    ,(case 
        when source_code = 'sofa_score' then source_code 
        else 'sofa - ' + source_code
        end) source_code
into #measurement_sofa
from stage.measurement_sofa
UNPIVOT (
    score for source_code IN (
         [SOFA_Score]
        ,[Cardiovascular]
        ,[CNS]
        ,[Coagulation]
        ,[Liver]
        ,[Renal]
        ,[Respiration]
    )
) x

SET NOCOUNT OFF;

insert into preload.measurement with (tablock)
select distinct 
    person_id = b.person_id
    ,measurement_concept_id = isnull(d.target_concept_id,0)
    ,measurement_date = a.date_of_care
    ,measurement_datetime = a.date_of_care
    ,measurement_time = a.date_of_care
    ,measurement_type_concept_id = 32817
    ,operator_concept_id = NULL
    ,value_as_number = a.SCORE
    ,value_as_concept_id = NULL
    ,unit_concept_id = 0
    ,range_low = NULL
    ,range_high = NULL
    ,provider_id = c.provider_id
    ,visit_occurrence_id = e.visit_occurrence_id
    ,visit_detail_id = NULL
    ,measurement_source_value = d.source_code
    ,measurement_source_concept_id = isnull(d.source_concept_id,0)
    ,unit_source_value = '{score}'
    ,value_source_value = a.SCORE
    ,source_table = 'measurement_sofa'
from #measurement_sofa a 
join xref.person_mapping b
on a.patient_key = b.patient_key
left join xref.provider_mapping c 
on c.providr_key = a.provider
left join xref.source_to_concept_map d 
on d.source_code = a.source_code and source_vocabulary_id = 'Flowsheet'
left join xref.visit_occurrence_mapping e 
on a.patnt_encntr_key = e.patnt_encntr_key

drop table if exists #measurement_sofa
