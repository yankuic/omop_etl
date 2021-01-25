-- drop table if exists preload.condition_occurrence
insert into preload.condition_occurrence
select distinct 
      b.[person_id]
      ,[condition_concept_id] = e.concept_id_2
      ,[condition_start_date] = a.START_DATE
      ,[condition_start_datetime] = a.START_DATE
      ,[condition_end_date] = a.END_DATE
      ,[condition_end_datetime] = a.END_DATE
      ,[condition_type_concept_id] = 32817
      ,[stop_reason] = NULL
      ,[provider_id] = c.provider_id
      ,[visit_occurrence_id] = 0
      ,[visit_detail_id] = 0
      ,[condition_source_value] = a.DIAG_CD_DECML
      ,[condition_source_concept_id] = d.concept_id
      ,[condition_status_source_value] = a.CONDITION_POA
      ,[condition_status_concept_id] = 0
from stage.condition a
join xref.person_mapping b
on a.patient_key = b.patient_key
left join xref.provider c
on a.providr_key = c.provider_source_value
left join xref.concept d
on a.diag_cd_decml = d.concept_code and (a.icd_type + 'CM' = d.vocabulary_id or a.icd_type = d.vocabulary_id)
join xref.concept_relationship e
on d.concept_id = e.concept_id_1 and e.relationship_id = 'Maps to'
join xref.concept f 
on e.concept_id_2 = f.concept_id and f.domain_id = 'Condition'
