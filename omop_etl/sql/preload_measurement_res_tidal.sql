SET NOCOUNT ON;

drop table if exists #measurement_res_tidal
SELECT patient_key
      ,patnt_encntr_key
      ,respiratory_date
      ,respiratory_datetime
      ,provider = isnull(attending_provider,visit_provider)
	  ,(case when tidal_measure = 'tidal_volume' then 'TIDAL VOLUME'
			 when tidal_measure = 'tidal_volume_exhaled' then 'TIDAL VOLUME EXHALED'
			 else NULL
		end) tidal_measure
	  ,tidal_value
  into #measurement_res_tidal
  FROM (
	select 
       patient_key
      ,patnt_encntr_key
      ,respiratory_date
      ,respiratory_datetime
      ,tidal_volume= try_convert(INT, tidal_volume)
      ,tidal_volume_exhaled = try_convert(INT, tidal_volume_exhaled)
      ,attending_provider
      ,visit_provider
	FROM stage.MEASUREMENT_Res_Tidal
) x
unpivot (
	tidal_value for tidal_measure in (
		 tidal_volume
		,tidal_volume_exhaled
	)
) pv;

SET NOCOUNT OFF;

insert into preload.measurement with (tablock)
select person_id = b.person_id
    ,measurement_concept_id = isnull(d.target_concept_id,0)
    ,measurement_date = a.Respiratory_Date
    ,measurement_datetime = a.Respiratory_Datetime
    ,measurement_time = CAST(a.Respiratory_Datetime as TIME)
    ,measurement_type_concept_id = 32817
    ,operator_concept_id = NULL
    ,value_as_number = a.tidal_value
    ,value_as_concept_id = NULL
    ,unit_concept_id = 8587
    ,range_low = NULL
    ,range_high = NULL
    ,provider_id = c.provider_id
    ,visit_occurrence_id = e.visit_occurrence_id
    ,visit_detail_id = NULL
    ,measurement_source_value = d.source_code
    ,measurement_source_concept_id = isnull(d.source_concept_id,0)
    ,unit_source_value = 'mL'
    ,value_source_value = a.tidal_measure
    ,source_table = 'measurement_res_tidal'
from #measurement_res_tidal a 
join xref.person_mapping b
on a.patient_key = b.patient_key
left join xref.provider_mapping c 
on c.providr_key = a.provider
left join xref.source_to_concept_map d 
on source_code = a.tidal_measure and source_vocabulary_id = 'Flowsheet'
left join xref.visit_occurrence_mapping e 
on a.patnt_encntr_key = e.patnt_encntr_key

drop table if exists #measurement_res_tidal
