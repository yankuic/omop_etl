drop table if exists stage.LOCATION
select distinct 
    ADDR_KEY
    ,ADDR1
    ,ADDR2
    ,a.CITY_NAME
    ,a.STATE_ABBRV
    ,ZIP5_CD as ZIP
    ,b.CNTY_NAME
    ,a.LATITUDE
    ,a.LONGITUDE
into stage.LOCATION
from dws_prod.dbo.ALL_ADDRESSES a
left join dws_prod.dbo.ZIP_CODE_MAPPER_XREF b 
on a.ZIP5_CD = b.ZIP_CD
