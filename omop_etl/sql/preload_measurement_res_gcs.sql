SET NOCOUNT ON;

drop table if exists #measurement_res_gcs
SELECT patient_key
      ,patnt_encntr_key
      ,respiratory_date
      ,respiratory_datetime
      ,provider=isnull(attending_provider, visit_provider)
	  ,(case when gcs_measure = 'glasgow_coma_peds_score' then 'GCS SCORE - Peds'
			 when gcs_measure = 'glasgow_coma_adult_score' then 'GCS SCORE - Adult'
			 else NULL
		end) gcs_measure
	  ,gcs_score
  INTO #measurement_res_gcs
  FROM stage.measurement_res_gcs
UNPIVOT (
	gcs_score for gcs_measure in (
		 glasgow_coma_peds_score
		,glasgow_coma_adult_score
	)
) pv;

SET NOCOUNT OFF;

insert into preload.measurement with (tablock)
select person_id = b.person_id
    ,measurement_concept_id = d.target_concept_id
    ,measurement_date = a.Respiratory_Date
    ,measurement_datetime = a.Respiratory_Datetime
    ,measurement_time = CAST(a.Respiratory_Datetime as TIME)
    ,measurement_type_concept_id = 32817
    ,operator_concept_id = NULL
    ,value_as_number = a.gcs_score
    ,value_as_concept_id = NULL
    ,unit_concept_id = 0
    ,range_low = NULL
    ,range_high = NULL
    ,provider_id = c.provider_id
    ,visit_occurrence_id = e.visit_occurrence_id
    ,visit_detail_id = NULL
    ,measurement_source_value = d.source_code
    ,measurement_source_concept_id = d.source_concept_id
    ,unit_source_value = NULL
    ,value_source_value = a.gcs_measure
    ,source_table = 'measurement_res_gcs'
from #measurement_res_gcs a 
join xref.person_mapping b
on a.patient_key = b.patient_key
left join xref.provider c 
on c.provider_source_value = a.provider
left join xref.source_to_concept_map d 
on source_code = a.gcs_measure and source_vocabulary_id = 'Flowsheet'
left join xref.visit_occurrence_mapping e 
on a.patnt_encntr_key = e.patnt_encntr_key

drop table if exists #measurement_res_gcs
