insert into dbo.location with (tablock) 
select b.location_id
    ,[addr1] 
    ,[addr2] 
    ,[city_name]
    ,[state_abbrv]
    ,[zip3_cd]
    ,[cnty_name]
    ,a.[addr_key]
from stage.location a 
join xref.location_mapping b 
on a.addr_key = b.addr_key 
where b.location_id in (
    select distinct location_id
    from (
        select location_id from person
        union 
        select location_id from care_site
    ) b
) 
and b.active_ind = 'Y'
