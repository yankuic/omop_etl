set nocount on;

;with bp as (
      --Extract bp vaues and deal with data types.
	select patient_key
            ,patnt_encntr_key
            ,bp_date
            ,bp_datetime
		,bp
            ,[bp - art line sbp] = try_convert(int,substring((bp),1,charindex('/',(bp),1)-1))
            ,[bp - art line dbp] = try_convert(int, substring((bp), charindex('/',(bp),1)+1, {fn length((bp))}-charindex('/',(bp),1)))
		,bp_non_invasive
            ,[non-invasive sbp] = try_convert(int, substring((bp_non_invasive),1,charindex('/',(bp_non_invasive),1)-1))
            ,[non-invasive dbp] = try_convert(int, substring((bp_non_invasive), charindex('/',(bp_non_invasive),1)+1, {fn length((bp_non_invasive))}-charindex('/',(bp_non_invasive),1)))
		,try_convert(varchar(50), cvp_mean) cvp_mean
            ,[map - central venous] = try_convert(int, cvp_mean)
		,try_convert(varchar(50), map_cuff) map_cuff
            ,[map - cuff] = try_convert(int, map_cuff)
            ,[map - non invasive] = try_convert(int, map_non_invasive)
		,try_convert(varchar(50), map_non_invasive) map_non_invasive
            ,[map - pulmonary] = try_convert(int, pap_mean)
		,try_convert(varchar(50), pap_mean) pap_mean
            ,[provider] = isnull(attending_provider, visit_provider)
      from stage.MEASUREMENT_BP
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
  FROM bp
cross apply (
      values ('bp - art line sbp', [bp - art line sbp], bp)
            ,('bp - art line dbp', [bp - art line dbp], bp)
		,('non-invasive sbp', [non-invasive sbp], bp_non_invasive)
		,('non-invasive dbp',[non-invasive dbp], bp_non_invasive)
		,('map - central venous',[map - central venous], cvp_mean)
		,('map - pulmonary',[map - pulmonary], pap_mean)
		,('map - cuff', [map - cuff], map_cuff)
		,('map - non invasive', [map - non invasive], map_non_invasive)
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
      ,measurement_source_value = d.source_code
      ,measurement_source_concept_id = isnull(d.source_concept_id, 0)
      ,unit_source_value = NULL
      ,value_source_value = a.bp_raw_value
      ,source_table = 'measurement_bp'
from #measurement_bp a 
join xref.person_mapping b
on a.patient_key = b.patient_key
left join xref.provider_mapping c 
on c.providr_key = a.provider
left join xref.source_to_concept_map d 
on d.source_code = a.bp_measure
left join xref.visit_occurrence_mapping e 
on a.patnt_encntr_key = e.patnt_encntr_key

drop table if exists #measurement_bp
