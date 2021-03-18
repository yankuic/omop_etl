-- truncate table preload.measurement
insert into preload.measurement with (tablock)
select person_id = b.person_id
      ,measurement_concept_id = isnull(d.target_concept_id,0)
      ,measurement_date = a.BP_DATE
      ,measurement_datetime = a.BP_DATETIME
      ,measurement_time = CAST(a.BP_DATETIME as TIME)
      ,measurement_type_concept_id = 32817
      ,operator_concept_id = NULL
      ,value_as_number = convert(int,substring((a.BP),1,charindex('/',(a.BP),1)-1))
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
      ,value_source_value = d.source_code
      ,source_table = 'measurement_bp'
from stage.measurement_bp a 
join xref.person_mapping b
on a.patient_key = b.patient_key
left join xref.provider c 
on c.provider_source_value = isnull(a.Attending_Provider, Visit_Provider)
left join xref.source_to_concept_map d 
on d.source_code = 'BP - Art Line SBP'
left join xref.visit_occurrence_mapping e 
on a.patnt_encntr_key = e.patnt_encntr_key

union 
select person_id = b.person_id
      ,measurement_concept_id = isnull(d.target_concept_id,0)
      ,measurement_date = a.BP_DATE
      ,measurement_datetime = a.BP_DATETIME
      ,measurement_time = CAST(a.BP_DATETIME as TIME)
      ,measurement_type_concept_id = 32817
      ,operator_concept_id = NULL
      ,value_as_number = convert(int, substring((a.BP), charindex('/',(a.BP),1)+1, {fn length((a.BP))}-charindex('/',(a.BP),1)))
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
      ,value_source_value = d.source_code
      ,source_table = 'measurement_bp'
from stage.measurement_bp a 
join xref.person_mapping b
on a.patient_key = b.patient_key
left join xref.provider c 
on c.provider_source_value = isnull(a.Attending_Provider, Visit_Provider)
left join xref.source_to_concept_map d 
on d.source_code = 'BP - Art Line DBP'
left join xref.visit_occurrence_mapping e 
on a.patnt_encntr_key = e.patnt_encntr_key
