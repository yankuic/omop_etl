insert into dbo.location with (tablock) 
select b.location_id
    --Use explicit truncation to avoid truncation errors
    ,[address_1] = left(addr1, 50)
    ,[address_2] = left(addr2, 50)
    ,[city_name]
    ,[state] = left(state_abbrv, 2)
    ,[zip]
    ,[county] = left(cnty_name, 20)
    ,[location_source_value] = left(a.[addr_key], 50)
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
