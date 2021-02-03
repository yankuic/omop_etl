insert into preload.procedure_occurrence with (tablock)
select distinct 
    b.[person_id]
    ,[procedure_concept_id] = e.concept_id_2
    ,[procedure_date] = a.START_DATE
    ,[procedure_datetime] = a.START_DATE
    ,[procedure_type_concept_id] = 32817
    ,[modifier_concept_id] = 0
    ,[quantity] = NULL 
    ,[provider_id] = c.provider_id
    ,[visit_occurrence_id] = e.visit_occurrence_id
    ,[visit_detail_id] = 0
    ,[procedure_source_value] = a.PROC_CD_DECML
    ,[procedure_source_concept_id] = d.concept_id
    ,[modifier_source_value] = NULL
    ,[source_table] = 'procedure_icd'
from [stage].[procedure_icd] a
join xref.person_mapping b
on a.patient_key = b.patient_key
left join xref.provider c
on a.PROVIDR_KEY = c.provider_source_value
inner join xref.concept d
on a.PROC_CD_DECML = d.concept_code and d.vocabulary_id like 'ICD%' 
join xref.concept_relationship e 
on d.concept_id = e.concept_id_1 and e.relationship_id = 'Maps to'
join xref.concept f 
on f.concept_id = e.concept_id_2 and f.domain_id = 'Procedure'
join xref.visit_occurrence_mapping g
on a.patnt_encntr_key = g.patnt_encntr_key
