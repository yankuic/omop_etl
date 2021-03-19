insert into dbo.location with (tablock)
select a.[location_id]
      ,[address_1] @SetNULL
      ,[address_2] @SetNULL
      ,[city]
      ,[state]
      ,[zip]
      ,[county]
      ,[location_source_value] @SetNULL
from xref.location a 
join (
    select distinct location_id
    from (
        select location_id from person
        union 
        select location_id from care_site
    ) b
) c
on a.location_id = c.location_id
