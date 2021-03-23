SET ANSI_WARNINGS OFF;

insert into @Schema.location with (tablock) (
       [location_id]
      ,[address_1] 
      ,[address_2] 
      ,[city]
      ,[state]
      ,[zip]
      ,[county]
      ,[location_source_value]
)
select location_id
      ,[addr1] @SetNULL
      ,[addr2] @SetNULL
      ,[city_name]
      ,[state_abbrv]
      ,[zip3_cd]
      ,[cnty_name]
      ,[addr_key] @SetNULL
from (
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
) x

SET ANSI_WARNINGS ON;
