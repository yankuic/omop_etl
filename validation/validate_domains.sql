select table_name = 'procedure_occurrence', test = 'Number of foreign domain_ids', count(distinct domain_id)
from preload.procedure_occurrence a
join xref.concept b
on a.procedure_concept_id = b.concept_id
where domain_id <> 'Procedure'
and b.domain_id <> 'Metadata'

select table_name = 'drug_exposure', test = 'Number of foreign domain_ids', count(distinct domain_id)
from dbo.drug_exposure a 
join xref.concept b 
on a.drug_concept_id = b.concept_id 
where b.domain_id <> 'Drug'
and b.domain_id <> 'Metadata'

declare @domain varchar(20)
set @domain = 'drug'

select table_name = 'drug_exposure', test = 'Has ' + @domain + 'domain_id?', count(distinct domain_id)
from dbo.drug_exposure a 
join xref.concept b 
on a.drug_concept_id = b.concept_id 
where b.domain_id = @domain

select table_name = 'condition_occurrence', test = 'Has ' + @domain + ' domain_id?', count(distinct domain_id)
from dbo.condition_occurrence a 
join xref.concept b 
on a.condition_concept_id = b.concept_id 
where b.domain_id = @domain

select table_name = 'procedure_occurrence', test = 'Has ' + @domain + ' domain_id?', count(distinct domain_id)
from dbo.procedure_occurrence a 
join xref.concept b 
on a.procedure_concept_id = b.concept_id 
where b.domain_id = @domain

select table_name = 'measurement', test = 'Has ' + @domain + ' domain_id?', count(distinct domain_id)
from dbo.measurement a 
join xref.concept b 
on a.measurement_concept_id = b.concept_id 
where b.domain_id = @domain

select table_name = 'observation', test = 'Has ' + @domain + ' domain_id?', count(distinct domain_id)
from dbo.observation a 
join xref.concept b 
on a.observation_concept_id = b.concept_id 
where b.domain_id = @domain

