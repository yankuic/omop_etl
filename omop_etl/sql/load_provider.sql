insert into dbo.provider with (tablock)
select a.[provider_id]
      ,[provider_name] @SetNULL
      ,[npi] @SetNULL
      ,[dea] @SetNULL
      ,[specialty_concept_id]
      ,[care_site_id]
      ,[year_of_birth]
      ,[gender_concept_id]
      ,[provider_source_value] @SetNULL
      ,[specialty_source_value]
      ,[specialty_source_concept_id]
      ,[gender_source_value]
      ,[gender_source_concept_id]
from xref.provider a
join (
    select distinct provider_id
    from (
        select provider_id from dbo.person
        union
        select provider_id from dbo.condition_occurrence
        union
        select provider_id from dbo.procedure_occurrence	
        union
        select provider_id from dbo.device_exposure
        union
        select provider_id from dbo.drug_exposure
        union 
        select provider_id from dbo.measurement
        union 
        select provider_id from dbo.note
        union
        select provider_id from dbo.observation
        union
        select provider_id from dbo.visit_detail
        union
        select provider_id from dbo.visit_occurrence
    ) b
) c
on a.provider_id = c.provider_id
