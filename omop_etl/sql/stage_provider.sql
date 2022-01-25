drop table if exists stage.PROVIDER
;with cte as (
  select distinct 
       a.PROVIDR_KEY 
      ,PROVIDR_NAME
      ,b.IDENT_ID
      ,b.IDENT_ID_TYPE
      ,b.LOOKUP_IND
      ,a.DEA_NUMBER
      ,a.BIRTH_DATE
      ,a.SEX_CD_KEY
      ,a.SPCLTY_DESC
      ,c.STNDRD_LABEL
from dws_prod.dbo.ALL_PROVIDERS a
left join dws_prod.dbo.ALL_PROVIDER_IDENTITIES b 
on a.PROVIDR_KEY = b.PROVIDR_KEY 
left join dws_prod.dbo.ALL_SEXES c 
on c.SEX_CD_KEY = a.SEX_CD_KEY and c.SOURCE_SYS = a.SOURCE_SYS 
), 
/* SELECT PROVIDERS WITH  NPI */
npi_cte as (
	select 
		PROVIDR_KEY 
		,PROVIDR_NAME
		,IDENT_ID
		,IDENT_ID_TYPE
		,LOOKUP_IND
		,DEA_NUMBER
		,BIRTH_DATE
		,SEX_CD_KEY
		,SPCLTY_DESC
		,STNDRD_LABEL
	from cte 
	where IDENT_ID_TYPE  = '100001'  --This is the ident_id_type for provider NPI
	and LOOKUP_IND = 'Y'  
)
/* STAGE PROVIDER TABLE */
select *
into stage.PROVIDER 
from (
	/* SELECT PROVIDERS WITH  NPI */
	select * 
	from npi_cte
	union
	/* SELECT PROVIDERS WITHOUT  NPI */
	select distinct 
		PROVIDR_KEY 
		,PROVIDR_NAME
		,NULL
		,IDENT_ID_TYPE
		,LOOKUP_IND
		,DEA_NUMBER
		,BIRTH_DATE
		,SEX_CD_KEY
		,SPCLTY_DESC
		,STNDRD_LABEL
	from cte 
	where providr_key not in (
	  select providr_key 
	  from npi_cte
	) 
) x
