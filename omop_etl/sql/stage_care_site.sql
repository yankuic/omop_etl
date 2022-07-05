drop table if exists stage.CARE_SITE
select distinct
	ADDR_KEY
	,RPT_LVL4_DESC
	,CURR_LOCATN_NAME
	,LOCATN_KEY
	,DEPT_ID 
	,DEPT_NAME
	,POS_TYPE_DESC
into stage.CARE_SITE
from dws_prod.dbo.ALL_HOSPITAL_ORGANIZATIONS a
where DEPT_ID is not null
and DEPT_ID <> '0'
