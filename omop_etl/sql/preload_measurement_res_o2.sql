SET NOCOUNT ON;

drop table if exists #measurement_res_o2
SELECT [patient_key]
      ,[patnt_encntr_key]
      ,[respiratory_date]
      ,[respiratory_datetime]
      ,provider=isnull([attending_provider],[visit_provider])
	  ,(case when o2_measure = 'o2_mlmin' then 'O2 FLOW RATE - mL/MIN'
			 when o2_measure = 'o2_lmin' then 'O2 FLOW RATE - L/MIN'
			 else NULL
		 end) o2_measure
	  ,o2_value
  INTO #measurement_res_o2
  FROM [stage].[MEASUREMENT_Res_O2]
UNPIVOT (
	o2_value for o2_measure in (
		[o2_lmin]
       ,[o2_mlmin]
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
    ,value_as_number = a.o2_value
    ,value_as_concept_id = NULL
    ,unit_concept_id = 8698
    ,range_low = NULL
    ,range_high = NULL
    ,provider_id = c.provider_id
    ,visit_occurrence_id = e.visit_occurrence_id
    ,visit_detail_id = NULL
    ,measurement_source_value = d.source_code
    ,measurement_source_concept_id = isnull(d.source_concept_id,0)
    ,unit_source_value = 'L/min'
    ,value_source_value = a.o2_measure
    ,source_table = 'measurement_res_o2'
from #measurement_res_o2 a 
join xref.person_mapping b
on a.patient_key = b.patient_key
left join xref.provider c 
on c.provider_source_value = a.provider
left join xref.source_to_concept_map d 
on source_code = a.o2_measure and source_vocabulary_id = 'Flowsheet'
left join xref.visit_occurrence_mapping e 
on a.patnt_encntr_key = e.patnt_encntr_key
