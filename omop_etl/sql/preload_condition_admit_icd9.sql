--Subset icd9 codes with no icd9cm equivalent.
SET NOCOUNT ON;

drop table if exists #icd
select concept_id, 
       domain_id, 
	 concept_code, 
	 vocabulary_id 
into #icd
from xref.concept
where vocabulary_id = 'ICD9'
and concept_code not in (
	select concept_code
	from xref.concept
	where vocabulary_id = 'ICD9CM'
)

SET NOCOUNT OFF;

insert into preload.condition_occurrence with (tablock)
select distinct
      b.[person_id]
      ,[condition_concept_id] = isnull(e.concept_id_2,0)
      ,[condition_start_date] = a.admit_date
      ,[condition_start_datetime] = a.admit_date
      ,[condition_end_date] = NULL  --a.discharge_date  [Note: diagnosis typically do not have an end date. Only diagnosis from problem list might have an end date.]
      ,[condition_end_datetime] = NULL  --a.discharge_date
      ,[condition_type_concept_id] = 32823
      ,[stop_reason] = NULL
      ,[provider_id] = c.provider_id  
      ,[visit_occurrence_id] = f.visit_occurrence_id
      ,[visit_detail_id] = NULL
      ,[condition_source_value] = a.admit_icd9
      ,[condition_source_concept_id] = isnull(d.concept_id, 0)
      ,[condition_status_source_value] = 'admit diagnosis' 
      ,[condition_status_concept_id] = 32890
      ,[source_table] = 'admit_icd9'
      ,[icd_type] = 'ICD9'
from stage.condition_admit_icd9 a
join xref.person_mapping b
on a.patient_key = b.patient_key
left join xref.provider_mapping c
on a.providr_key = c.providr_key
--join to map to standard concepts
left join xref.concept d
on a.admit_icd9 = d.concept_code and d.vocabulary_id = 'ICD9CM'
left join xref.concept_relationship e
on d.concept_id = e.concept_id_1 and e.relationship_id = 'Maps to'
left join xref.visit_occurrence_mapping f
on a.patnt_encntr_key = f.patnt_encntr_key
where b.active_ind = 'Y'
and a.admit_icd9 <> '?'

union 
-- Load ICD codes with no ICD CM equivalent.
select distinct
      b.[person_id]
      ,[condition_concept_id] = isnull(e.concept_id_2,0)
      ,[condition_start_date] = a.admit_date
      ,[condition_start_datetime] = a.admit_date
      ,[condition_end_date] = NULL  --a.discharge_date  [Note: diagnosis typically do not have an end date. Only diagnosis from problem list might have an end date.]
      ,[condition_end_datetime] = NULL  --a.discharge_date
      ,[condition_type_concept_id] = 32823
      ,[stop_reason] = NULL
      ,[provider_id] = c.provider_id  
      ,[visit_occurrence_id] = f.visit_occurrence_id
      ,[visit_detail_id] = NULL
      ,[condition_source_value] = a.admit_icd9
      ,[condition_source_concept_id] = isnull(d.concept_id, 0)
      ,[condition_status_source_value] = 'admit diagnosis' 
      ,[condition_status_concept_id] = 32890
      ,[source_table] = 'admit_icd9'
      ,[icd_type] = 'ICD9'
from stage.condition_admit_icd9 a
join xref.person_mapping b
on a.patient_key = b.patient_key
left join xref.provider_mapping c
on a.providr_key = c.providr_key
--join to map to standard concepts
join #icd d
on a.admit_icd9 = d.concept_code and d.vocabulary_id = 'ICD9'
left join xref.concept_relationship e
on d.concept_id = e.concept_id_1 and e.relationship_id = 'Maps to'
left join xref.visit_occurrence_mapping f
on a.patnt_encntr_key = f.patnt_encntr_key
where b.active_ind = 'Y'
and a.admit_icd9 <> '?'
