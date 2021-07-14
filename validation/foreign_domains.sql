declare @domain varchar(20)
set @domain = 'Observation'

select distinct condition_source_value, vocabulary_id, domain_id, ICD_TYPE, DIAG_CD_LVL2_DESC
from preload.condition_occurrence a
join xref.concept b
on a.condition_concept_id = b.concept_id
join dws_prod.dbo.ALL_ICD_DIAGNOSIS_CODES c
on a.condition_source_value = c.DIAG_CD_DECML
where domain_id = @domain

--It seems no hcpcs code is loaded
select distinct procedure_source_value, vocabulary_id, domain_id, CPT_CD_TYPE, CPT_CD_LVL1_DESC,CPT_CD_LVL2_DESC 
from preload.procedure_occurrence a
join xref.concept b
on a.procedure_concept_id = b.concept_id
join dws_prod.dbo.ALL_CPT_PROCEDURE_CODES c
on a.procedure_source_value = c.CPT_CD
where domain_id = 'Procedure' --@domain
and CPT_CD_TYPE = 'CPT'
order by procedure_source_value


--select top 100 * from dws_prod.dbo.ALL_CPT_PROCEDURE_CODES

select distinct measurement_source_value, vocabulary_id, domain_id 
from preload.measurement a
join xref.concept b
on a.measurement_concept_id = b.concept_id
where domain_id = @domain

--select distinct observation_concept_id, observation_source_value, vocabulary_id, domain_id 
--from preload.observation a
--join xref.concept b
--on a.observation_concept_id = b.concept_id
--where domain_id = @domain

select distinct drug_source_value, vocabulary_id, domain_id 
from preload.drug_exposure a
join xref.concept b
on a.drug_concept_id = b.concept_id
where domain_id = @domain

select distinct drug_concept_id, drug_source_value 
from dbo.drug_exposure
--where drug_source_value = '2532-0'

select * --distinct observation_concept_id, value_as_string 
from dbo.observation
where observation_source_value = '2532-0'

select * from xref.concept
where vocabulary_id like 'rxnorm%'
and concept_code = '198228'

select top 1 *
from dbo.drug_exposure
where drug_source_value = '198228'

--FIX concept_id for covid labs

select top 1000 * 
from dws_prod.dbo.ALL_MEDICATIONS

select top 1000 * from observation
where observation_source_value = 'zipcode'
order by person_id

select * from xref.concept
where concept_code = '70199-5'

--update dbo.measurement
--set value_as_concept_id = 4172976
--where value_source_value = 'Equivocal'

--update hipaa.measurement
--set value_as_concept_id = 4172976
--where value_source_value = 'Equivocal'

