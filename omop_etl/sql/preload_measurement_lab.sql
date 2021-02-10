--bypass truncation warnings
SET ANSI_WARNINGS OFF

insert into preload.measurement with (tablock)
select distinct 
      person_id = b.person_id
      ,measurement_concept_id = e.concept_id_2
      ,measurement_date = isnull(a.SPECIMEN_TAKEN_DATE, a.INFERRED_SPECIMEN_DATE)
      ,measurement_datetime = isnull(a.SPECIMEN_TAKEN_DATETIME, a.INFERRED_SPECIMEN_DATETIME)
      ,measurement_time = isnull(a.SPECIMEN_TAKEN_TIME, a.INFERRED_SPECIMEN_TIME)
      ,measurement_type_concept_id = 32817
      ,operator_concept_id = NULL
      ,value_as_number = try_convert(float, a.LAB_RESULT)
      ,value_as_concept_id = NULL
      ,unit_concept_id = g.concept_id
      ,range_low = try_convert(float, a.NORMAL_LOW)
      ,range_high = try_convert(float, a.NORMAL_HIGH)
      ,provider_id = c.provider_id
      ,visit_occurrence_id = h.visit_occurrence_id
      ,visit_detail_id = NULL
      ,measurement_source_value = a.INFERRED_LOINC_CODE
      ,measurement_source_concept_id = d.concept_id
      ,unit_source_value = a.LAB_UNIT
      ,value_source_value = a.LAB_RESULT
      ,source_table = 'measurement_lab'
from stage.measurement_lab a 
join xref.person_mapping b
on a.patient_key = b.patient_key
join xref.provider c 
on c.provider_source_value = a.Attending_Provider
left join xref.concept d 
on a.INFERRED_LOINC_CODE = d.concept_code and d.vocabulary_id = 'LOINC'
join xref.concept_relationship e
on d.concept_id = e.concept_id_1 and e.relationship_id = 'Maps to'
join xref.concept f
on e.concept_id_2 = f.concept_id and f.domain_id = 'Measurement'
left join xref.concept g 
on a.LAB_UNIT = g.concept_code and g.domain_id = 'Unit'
join xref.visit_occurrence_mapping h 
on a.patnt_encntr_key = h.patnt_encntr_key

SET ANSI_WARNINGS ON