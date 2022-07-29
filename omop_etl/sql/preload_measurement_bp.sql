drop table if exists #measurement_bp

set nocount on;

;with bp as (
    --Extract bp values and deal with data types.
	select patient_key
            ,patnt_encntr_key
            ,bp_date
            ,bp_datetime
			,bp
            ,[bp - sbp] = try_convert(int, substring((bp), 1, charindex('/',(bp),1)-1))
            ,[bp - dbp] = try_convert(int, substring((bp), charindex('/',(bp),1)+1, {fn length((bp))}-charindex('/',(bp),1)))
            ,bp_method
            ,[provider] = isnull(attending_provider, visit_provider)
      from stage.MEASUREMENT_BP_BP
      where charindex('/',(bp),1) > 0 --accept only values with format ##/##
)

SELECT * 
INTO #measurement_bp
from (
      SELECT patient_key
            ,patnt_encntr_key
            ,bp_date
            ,bp_datetime
            ,provider
            ,(case 
                  when (bp_method = 'Arterial Line' or bp_method = 'UAC') then 'BP - Art Line SBP' 
                  when (bp_method = 'Manual (Cuff)' or bp_method = 'Automatic' or bp_method = 'Doppler') then 'BP - Non-invasive SBP'
                  else 'SBP - Unknown method'
            end) bp_measure
            ,bp_value = [bp - sbp]
            ,bp_raw_value = bp   
      FROM bp
      WHERE bp is not null   
      UNION
      SELECT patient_key
            ,patnt_encntr_key
            ,bp_date
            ,bp_datetime
            ,provider
            ,(case 
                  when (bp_method = 'Arterial Line' or bp_method = 'UAC') then 'BP - Art Line DBP' 
                  when (bp_method = 'Manual (Cuff)' or bp_method = 'Automatic' or bp_method = 'Doppler') then 'BP - Non-invasive DBP'
                  else 'DBP - Unknown method'
            end) bp_measure
            ,vp_value = [bp - dbp]
            ,bp_raw_value = bp
      FROM bp
      WHERE bp is not null  
) x

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
      ,visit_occurrence_id = isnull(f.visit_occurrence_id,e.visit_occurrence_id)
      ,visit_detail_id = f.visit_detail_id
      ,measurement_source_value = isnull(d.source_code, a.bp_measure)
      ,measurement_source_concept_id = isnull(d.source_concept_id, 0)
      ,unit_source_value = NULL
      ,value_source_value = a.bp_raw_value
      ,source_table = 'measurement_bp_bp'
from #measurement_bp a 
join xref.person_mapping b
on a.patient_key = b.patient_key
left join xref.provider_mapping c 
on c.providr_key = a.provider and c.providr_key > 0
left join xref.source_to_concept_map d 
on d.source_code = a.bp_measure
left join xref.visit_occurrence_mapping e 
on a.patnt_encntr_key = e.patnt_encntr_key
left join xref.visit_detail_mapping f
on a.patnt_encntr_key = f.patnt_encntr_key
where b.active_ind = 'Y'

drop table if exists #measurement_bp
