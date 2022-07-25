drop table if exists #measurement_bp
set nocount on;

;with bp_cvp as (
    --Extract bp values and deal with data types.
	select patient_key
            ,patnt_encntr_key
            ,bp_date
            ,bp_datetime
    		,try_convert(varchar(50), cvp) cvp  --what is the reason for conversion? Why not convert to float rather than varchar?
            ,[provider] = isnull(attending_provider, visit_provider)
      from stage.MEASUREMENT_BP_CVP      
)

SELECT patient_key
      ,patnt_encntr_key
      ,bp_date
      ,bp_datetime
      ,provider
      ,bp_measure
      ,bp_value
	,bp_raw_value
	INTO #measurement_bp
  FROM bp_cvp
cross apply (
      values ('CVP - Central Venous Pressure', [cvp], cvp)
) pv(bp_measure, bp_value, bp_raw_value)
where bp_raw_value is not null

set nocount off;

insert into preload.measurement with (tablock)
select person_id = b.person_id
      ,measurement_concept_id = isnull(d.target_concept_id, 0)
      ,measurement_date = a.BP_DATE
      ,measurement_datetime = a.BP_DATETIME
      ,measurement_time = CAST(a.BP_DATETIME as TIME)
      ,measurement_type_concept_id = 32817
      ,operator_concept_id = NULL
      ,value_as_number = a.bp_value
      ,value_as_concept_id = NULL
      ,unit_concept_id = NULL
      ,range_low = NULL
      ,range_high = NULL
      ,provider_id = c.provider_id
      ,visit_occurrence_id = e.visit_occurrence_id
      ,visit_detail_id = NULL
      ,measurement_source_value = isnull(d.source_code, a.bp_measure)
      ,measurement_source_concept_id = isnull(d.source_concept_id, 0)
      ,unit_source_value = NULL
      ,value_source_value = a.bp_raw_value
      ,source_table = 'measurement_bp_cvp'
from #measurement_bp a 
join xref.person_mapping b
on a.patient_key = b.patient_key
left join xref.provider_mapping c 
on c.providr_key = a.provider and c.providr_key > 0
left join xref.source_to_concept_map d 
on d.source_code = a.bp_measure
left join xref.visit_occurrence_mapping e 
on a.patnt_encntr_key = e.patnt_encntr_key
where b.active_ind = 'Y'

drop table if exists #measurement_bp
