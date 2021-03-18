insert into preload.procedure_occurrence with (tablock)
select distinct 
    b.[person_id]
    ,[procedure_concept_id] = isnull(e.concept_id_2,0)
    ,[procedure_date] = a.START_DATE
    ,[procedure_datetime] = a.START_DATE
    ,[procedure_type_concept_id] = 32817
    ,[modifier_concept_id] = 0
    ,[quantity] = 1 
    ,[provider_id] = c.provider_id
    ,[visit_occurrence_id] = g.visit_occurrence_id
    ,[visit_detail_id] = 0
    ,[procedure_source_value] = a.CPT_CD
    ,[procedure_source_concept_id] = isnull(d.concept_id, 0)
    ,[modifier_source_value] = NULL
    ,[source_table] = 'procedure_cpt'
from [stage].[procedure_cpt] a
join xref.person_mapping b
on a.patient_key = b.patient_key
left join xref.provider c
on a.providr_key = c.provider_source_value
left join xref.concept d 
on d.concept_code = a.CPT_CD and d.vocabulary_id = 'CPT4'
left join xref.concept_relationship e 
on d.concept_id = e.concept_id_1 and e.relationship_id = 'Maps to'
-- join xref.concept f 
-- on f.concept_id = e.concept_id_2 and f.domain_id = 'Procedure'
left join xref.visit_occurrence_mapping g
on a.patnt_encntr_key = g.patnt_encntr_key
