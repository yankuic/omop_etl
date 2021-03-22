/****** Script for SelectTopNRows command from SSMS  ******/
-- insert into [DWS_OMOP].dbo.[location] (
--     [location_id]
--     ,[address_1]
--     ,[address_2]
--     ,[city]
--     ,[state]
--     ,[zip]
--     ,[county]
--     ,[location_source_value]
-- )
drop table if exists stage.LOCATION
select distinct 
    ADDR_KEY
    ,ADDR1
    ,ADDR2
    ,a.CITY_NAME
    ,a.STATE_ABBRV
    ,ZIP3_CD
    ,b.CNTY_NAME
    ,NULL 
    ,a.LATITUDE
    ,a.LONGITUDE
into stage.LOCATION
from dws_prod.dbo.ALL_ADDRESSES a
left join dws_prod.dbo.ZIP_CODE_MAPPER_XREF b 
on a.ZIP5_CD = b.ZIP_CD

--Validation
-- SELECT * FROM [DWS_OMOP].DBO.[LOCATION] where location_id = 7157560
-- SELECT * FROM [DWS_OMOP].DBO.[LOCATION_v6] where location_id = 7157560
--SELECT * FROM DWS_OMOP.DBO.[PROVIDER] where provider_id = 1 

;with cte as(
  select distinct 
      a.PROVIDR_KEY 
      ,PROVIDR_NAME
      ,b.IDENT_ID
      ,b.IDENT_ID_TYPE
      ,b.LOOKUP_IND
      ,a.DEA_NUMBER
      ,null as specialty_concept_id
      ,null as care_site_id
      ,year(a.BIRTH_DATE) as year_of_birth
      ,(case 
          when a.SEX_CD_KEY = 1 then 8532 
          when a.SEX_CD_KEY = 2 then 8507 
          else NULL 
        end) gender_concept_id
      ,provider_source_value = a.PROVIDR_KEY
      ,a.SPCLTY_DESC as specialty_source_value
      ,0 as specialty_source_concept_id
      ,c.STNDRD_LABEL as gender_source_value 
      ,0 as gender_source_concept_id
from dws_prod.dbo.ALL_PROVIDERS a
left join dws_prod.dbo.ALL_PROVIDER_IDENTITIES b 
on a.PROVIDR_KEY = b.PROVIDR_KEY 
left join dws_prod.dbo.ALL_SEXES c 
on c.SEX_CD_KEY = a.SEX_CD_KEY and c.SOURCE_SYS = a.SOURCE_SYS 
--where a.PROVIDR_KEY = 4377
)

/* THIS TO INSERT ALL PROVIDERS WITHOUT  NPI */
insert into dws_omop.dbo.provider (
    [provider_name]
    ,[NPI]
    ,[DEA]
    ,[specialty_concept_id]
    ,[care_site_id]
    ,[year_of_birth]
    ,[gender_concept_id]
    ,[provider_source_value]
    ,[specialty_source_value]
    ,[specialty_source_concept_id]
    ,[gender_source_value]
    ,[gender_source_concept_id])
select distinct 
    PROVIDR_NAME
    ,NULL
    ,DEA_NUMBER
    ,[specialty_concept_id]
    ,[care_site_id]
    ,[year_of_birth]
    ,[gender_concept_id]
    ,[provider_source_value]
    ,[specialty_source_value]
    ,[specialty_source_concept_id]
    ,[gender_source_value]
    ,[gender_source_concept_id]
from cte 
where providr_key not in (
  select provider_source_value 
  from DWS_OMOP.DBO.[PROVIDER]
) 

/* THIS TO INSERT ALL PROVIDERS WITH  NPI */
insert into dws_omop.dbo.provider (
    [provider_name]
    ,[NPI]
    ,[DEA]
    ,[specialty_concept_id]
    ,[care_site_id]
    ,[year_of_birth]
    ,[gender_concept_id]
    ,[provider_source_value]
    ,[specialty_source_value]
    ,[specialty_source_concept_id]
    ,[gender_source_value]
    ,[gender_source_concept_id]
)
select 
    PROVIDR_NAME
    ,IDENT_ID
    ,DEA_NUMBER
    ,[specialty_concept_id]
    ,[care_site_id]
    ,[year_of_birth]
    ,[gender_concept_id]
    ,[provider_source_value]
    ,[specialty_source_value]
    ,[specialty_source_concept_id]
    ,[gender_source_value]
    ,[gender_source_concept_id] 
from cte 
where IDENT_ID_TYPE  = '100001'  and LOOKUP_IND = 'Y'  
  

/*UPDATE PROVIDER SOURCE VALUE TO SOURCE_PROVIDR_ID*/
--update DWS_OMOP.DBO.[PROVIDER]
--set provider_source_value = b.SOURCE_PROVIDR_ID
--from DWS_OMOP.DBO.[PROVIDER] a
--left join ALL_PROVIDERS b on a.provider_source_value = b.PROVIDR_KEY  

select distinct  
    a.*
    ,b.SOURCE_PROVIDR_ID
    ,b.PROVIDR_KEY 
from DWS_OMOP.DBO.[PROVIDER] a
left join ALL_PROVIDERS b 
on a.provider_source_value = b.PROVIDR_KEY  


/*OLD CODE FOR PROVIDER */
--insert into dws_omop.dbo.provider([provider_id],[provider_name],[NPI],[DEA],[specialty_concept_id],[care_site_id],[year_of_birth],[gender_concept_id],[provider_source_value],[specialty_source_value],[specialty_source_concept_id],[gender_source_value],[gender_source_concept_id])
--select a.PROVIDR_KEY , PROVIDR_NAME, IDENT_ID ,a.DEA_NUMBER, null, null,year(a.BIRTH_DATE),
--case when a.SEX_CD_KEY = 1 then 8532 
--	when a.SEX_CD_KEY = 2 then 8507 else NULL end , NULL, a.SPCLTY_DESC, 0, c.STNDRD_LABEL , 0
--  from ALL_PROVIDERS a
--join ALL_PROVIDER_IDENTITIES b on a.PROVIDR_KEY = b.PROVIDR_KEY and b.LOOKUP_IND = 'Y' 
--join ALL_SEXES c on c.SEX_CD_KEY = a.SEX_CD_KEY and c.SOURCE_SYS = 'EPIC' 



--select top 5 *, year(BIRTH_DATE) from ALL_PROVIDERS where BIRTH_DATE is not null 


--select top 5 * from ALL_PROVIDER_IDENTITIES where IDENT_ID_TYPE  = '100001'  and LOOKUP_IND = 'Y' 


--SELECT * 
--  FROM [DWS_OMOP].dbo.provider
--where provider_id = 4377

----insert into [DWS_OMOP].dbo.[location]([location_id],[address_1],[address_2],[city],[state],[zip],[county],[location_source_value])
--select distinct ADDR_KEY, ADDR1, ADDR2, a.CITY_NAME, a.STATE_ABBRV,ZIP3_CD, b.CNTY_NAME, NULL 
--from dws_prod.dbo.ALL_ADDRESSES a
--left join ZIP_CODE_MAPPER_XREF b on a.ZIP5_CD = b.ZIP_CD
--where ADDR_KEY = 660503

--begin tran
--update [DWS_OMOP].dbo.[location]
--set [county] = b.CNTY_NAME
--from dws_prod.dbo.ALL_ADDRESSES a
--left join ZIP_CODE_MAPPER_XREF b on a.ZIP5_CD = b.ZIP_CD
--commit


--update [DWS_OMOP].dbo.provider
--set provider_source_value = provider_id

--update dws_omop.dbo.location
--set location_source_value = location_id 

--update dws_omop.dbo.location_v6
--set location_source_value = location_id 


select * from DWS_OMOP.dbo.care_site 

--insert into DWS_OMOP.dbo.care_site([care_site_name],[place_of_service_concept_id],[location_id],[care_site_source_value],[place_of_service_source_value])

--select RPT_LVL4_DESC, NULL, b.location_id, DEPT_ID, null  from ALL_HOSPITAL_ORGANIZATIONS a
--left join DWS_OMOP.dbo.location b on a.ADDR_KEY = b.location_source_value 