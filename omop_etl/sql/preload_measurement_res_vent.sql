SET NOCOUNT ON;

drop table if exists #measurement_res_vent
SELECT [patient_key]
      ,[patnt_encntr_key]
      ,[respiratory_date]
      ,[respiratory_datetime]
      ,provider = isnull([attending_provider],[visit_provider])
      ,vent_measure
	  ,vent_value
  INTO #measurement_res_vent
  FROM stage.MEASUREMENT_Res_Vent
  cross apply (
      values ('VENT START - Adult', respiratory_vent_bgn)
            ,('VENT STOP - Adult', respiratory_vent_end)
  ) pv(vent_measure, vent_value)

SET NOCOUNT OFF;

insert into preload.measurement with (tablock)
select person_id = b.person_id
    ,measurement_concept_id = isnull(d.target_concept_id,0)
    ,measurement_date = a.Respiratory_Date
    ,measurement_datetime = a.Respiratory_Datetime
    ,measurement_time = CAST(a.Respiratory_Datetime as TIME)
    ,measurement_type_concept_id = 32817
    ,operator_concept_id = NULL
    ,value_as_number = try_convert(float, a.vent_value)
    ,value_as_concept_id = NULL
    ,unit_concept_id = NULL
    ,range_low = NULL
    ,range_high = NULL
    ,provider_id = c.provider_id
    ,visit_occurrence_id = e.visit_occurrence_id
    ,visit_detail_id = NULL
    ,measurement_source_value = d.source_code
    ,measurement_source_concept_id = isnull(d.source_concept_id,0)
    ,unit_source_value = NULL
    ,value_source_value = a.vent_value
    ,source_table = 'measurement_res_vent'
from #measurement_res_vent a 
join xref.person_mapping b
on a.patient_key = b.patient_key
left join xref.provider_mapping c 
on c.providr_key = a.provider
left join xref.source_to_concept_map d 
on source_code = a.vent_measure and source_vocabulary_id = 'Flowsheet'
left join xref.visit_occurrence_mapping e 
on a.patnt_encntr_key = e.patnt_encntr_key
where b.active_ind = 'Y'

union 
select person_id = b.person_id
    ,measurement_concept_id = isnull(d.target_concept_id, 0)
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
    ,measurement_source_concept_id = isnull(d.source_concept_id, 0)
    ,unit_source_value = NULL
    ,value_source_value = left(a.adult_vent_mode, 50)
    ,source_table = 'measurement_res_vent'
from stage.MEASUREMENT_Res_Vent a 
join xref.person_mapping b
on a.patient_key = b.patient_key
left join xref.provider_mapping c 
on c.providr_key = isnull(a.attending_provider, a.visit_provider)
left join xref.source_to_concept_map d 
on source_code = 'VENT MODE - Adult' and source_vocabulary_id = 'Flowsheet'
left join xref.visit_occurrence_mapping e 
on a.patnt_encntr_key = e.patnt_encntr_key
where b.active_ind = 'Y'

drop table if exists #measurement_res_vent
