insert into dbo.visit_occurrence with (tablock)
select visit_occurrence_id = b.visit_occurrence_id
      ,person_id = c.person_id
      ,visit_concept_id = g.target_concept_id
      ,visit_start_date = a.ENCOUNTER_EFFECTIVE_DATE
      ,visit_start_datetime = a.ENCOUNTER_EFFECTIVE_DATE
      ,visit_end_date = isnull(a.DISCHG_DATE, a.ENCOUNTER_EFFECTIVE_DATE)
      ,visit_end_datetime = isnull(a.DISCHG_DATETIME, a.ENCOUNTER_EFFECTIVE_DATE)
      ,visit_type_concept_id = 32817
      ,provider_id = d.provider_id
      ,care_site_id = NULL
      ,visit_source_value = a.patient_type 
      ,visit_source_concept_id = g.source_concept_id
      ,admitting_source_concept_id =  e.source_concept_id
      ,admitting_source_value = a.ADMIT_SOURCES
      ,discharge_to_concept_id = f.source_concept_id
      ,discharge_to_source_value = a.DISCHG_DISPOSITION
      ,preceding_visit_occurrence_id = NULL
from stage.visit a 
join xref.visit_occurrence_mapping b 
on a.patnt_encntr_key = b.patnt_encntr_key
join xref.person_mapping c
on a.patient_key = c.patient_key
left join xref.provider_mapping d
on d.providr_key = isnull(a.attending_provider, a.VISIT_PROVIDER)
left join xref.source_to_concept_map e 
on a.ADMIT_SOURCES = e.source_code and e.source_vocabulary_id = 'Admit Source'
left join xref.source_to_concept_map f 
on a.DISCHG_DISPOSITION = f.source_code and f.source_vocabulary_id = 'Discharge Dis'
left join xref.source_to_concept_map g
on a.PATIENT_TYPE = g.source_code and g.source_vocabulary_id = 'Patient Type'
left join xref.care_site_mapping h
on h.dept_id = a.dept_id
where a.DISCHG_DATE is not null 
or (a.DISCHG_DATE is null and a.PATIENT_TYPE not in ('OUTPATIENT', 'INPATIENT'))
