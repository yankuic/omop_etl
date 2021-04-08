insert into dbo.provider with (tablock) 
select distinct 
    [provider_id] = b.provider_id
    ,[provider_name] = a.providr_name
    ,[npi] = a.ident_id
    ,[dea] = a.dea_number
    ,[specialty_concept_id] = NULL
    ,[care_site_id] = NULL
    ,[year_of_birth] = YEAR(a.birth_date)
    ,(case 
        when a.SEX_CD_KEY = 1 then 8532 
        when a.SEX_CD_KEY = 2 then 8507 
        else NULL 
        end) gender_concept_id
    ,[provider_source_value] = b.providr_key
    ,[specialty_source_value] = a.SPCLTY_DESC
    ,[specialty_source_concept_id] = NULL
    ,[gender_source_value] = a.STNDRD_LABEL
    ,[gender_source_concept_id] = 0
from stage.provider a
join xref.provider_mapping b 
on a.providr_key = b.providr_key 
where b.provider_id in (
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
    ) x
) 
and b.active_ind = 'Y'
