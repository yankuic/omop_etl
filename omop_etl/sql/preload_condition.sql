--Subset icd10 codes with no icd10cm equivalent.
SET NOCOUNT ON;

drop table if exists #icd
select concept_id, 
       domain_id, 
	 concept_code, 
	 vocabulary_id 
into #icd
from xref.concept
where (vocabulary_id = 'ICD10' OR vocabulary_id = 'ICD9') 
and concept_code not in (
	select concept_code
	from xref.concept
	where (vocabulary_id = 'ICD10CM' or vocabulary_id = 'ICD9CM')
)

SET NOCOUNT OFF;

insert into preload.condition_occurrence with (tablock)
select distinct 
      b.[person_id]
      ,[condition_concept_id] = isnull(e.concept_id_2,0)
      ,[condition_start_date] = a.START_DATE
      ,[condition_start_datetime] = a.START_DATE
      ,[condition_end_date] = a.END_DATE
      ,[condition_end_datetime] = a.END_DATE
      ,(case 
            when diagnosis_type = 'ENCOUNTER' then 32827
            when (diagnosis_type = 'HOSPITAL BILLING CODED' or diagnosis_type = 'PROFESSSIONAL BILLING CHARGE') then 32821
            when diagnosis_type = 'PROBLEM LIST' then 32840
            else 32817
      end) condition_type_concept_id
      ,[stop_reason] = NULL
      ,[provider_id] = c.provider_id
      ,[visit_occurrence_id] = g.visit_occurrence_id
      ,[visit_detail_id] = NULL
      ,[condition_source_value] = a.DIAG_CD_DECML
      ,[condition_source_concept_id] = d.concept_id
      ,[condition_status_source_value] = a.CONDITION_POA
      ,[condition_status_concept_id] = NULL
from stage.condition a
join xref.person_mapping b
on a.patient_key = b.patient_key
left join xref.provider_mapping c
on a.providr_key = c.providr_key
left join xref.concept d
on a.diag_cd_decml = d.concept_code and a.icd_type + 'CM' = d.vocabulary_id
left join xref.concept_relationship e
on d.concept_id = e.concept_id_1 and e.relationship_id = 'Maps to'
left join xref.visit_occurrence_mapping g
on a.patnt_encntr_key = g.patnt_encntr_key

union 
-- Load ICD codes with no ICD CM equivalent.
select distinct 
      b.[person_id]
      ,[condition_concept_id] = isnull(e.concept_id_2,0)
      ,[condition_start_date] = a.START_DATE
      ,[condition_start_datetime] = a.START_DATE
      ,[condition_end_date] = a.END_DATE
      ,[condition_end_datetime] = a.END_DATE
      ,(case 
            when diagnosis_type = 'ENCOUNTER' then 32827
            when (diagnosis_type = 'HOSPITAL BILLING CODED' or diagnosis_type = 'PROFESSSIONAL BILLING CHARGE') then 32821
            when diagnosis_type = 'PROBLEM LIST' then 32840
            else 32817
      end) condition_type_concept_id
      ,[stop_reason] = NULL
      ,[provider_id] = c.provider_id
      ,[visit_occurrence_id] = g.visit_occurrence_id
      ,[visit_detail_id] = NULL
      ,[condition_source_value] = a.DIAG_CD_DECML
      ,[condition_source_concept_id] = isnull(d.concept_id,0)
      ,[condition_status_source_value] = a.CONDITION_POA
      ,[condition_status_concept_id] = NULL
from stage.condition a
join xref.person_mapping b
on a.patient_key = b.patient_key
left join xref.provider_mapping c
on a.providr_key = c.providr_key
join #icd d
on a.diag_cd_decml = d.concept_code and a.icd_type = d.vocabulary_id
left join xref.concept_relationship e
on d.concept_id = e.concept_id_1 and e.relationship_id = 'Maps to'
left join xref.visit_occurrence_mapping g
on a.patnt_encntr_key = g.patnt_encntr_key
