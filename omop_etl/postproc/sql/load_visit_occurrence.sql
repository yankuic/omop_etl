insert into dbo.visit_occurrence with (tablock)
select visit_occurrence_id - b.visit_occurrence_id
      ,person_id
      ,visit_concept_id
      ,visit_start_date = a.ENCOUNTER_EFFECTIVE_DATE
      ,visit_start_datetime = a.ENCOUNTER_EFFECTIVE_DATE
      ,visit_end_date = a.DISCHG_DATE
      ,visit_end_datetime = a.DISCHG_DATETIME 
      ,visit_type_concept_id = 32817
      ,provider_id = d.provider_id
      ,care_site_id = NULL
      ,visit_source_value = NULL --Yujun needs to add patient_type to bo query and populate the stage table.
      ,visit_source_concept_id = NULL
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
join xref.provider d
on a.VISIT_PROVIDER = c.provider_source_value
left join xref.source_to_concept_map e 
on a.ADMIT_SOURCES = d.source_value and d.source_vocabulary_id = 'Admit Source'
left join xref.source_to_concept_map f 
on a.ADMIT_SOURCES = d.source_value and d.source_vocabulary_id = 'Discharge Dis'
--left join xref.care_site --Scotts need to look into mapping between provider and care_site.
