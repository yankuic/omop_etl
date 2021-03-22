SET ANSI_WARNINGS OFF;

insert into dbo.location with (tablock) (
       [location_id]
      ,[address_1] 
      ,[address_2] 
      ,[city]
      ,[state]
      ,[zip]
      ,[county]
      ,[location_source_value]
)
select b.[location_id]
      ,[addr1] @SetNULL
      ,[addr2] @SetNULL
      ,[city_name]
      ,[state_abbrv]
      ,[zip3_cd]
      ,[cnty_name]
      ,a.[addr_key] @SetNULL
from stage.location a 
join xref.location_mapping b 
on a.addr_key = b.addr_key 
join (
    select distinct location_id
    from (
        select location_id from person
        union 
        select location_id from care_site
    ) b
) c
on b.location_id = c.location_id
where b.active_ind = 'Y'

SET ANSI_WARNINGS ON;
