insert into @Schema.care_site with (tablock) (
      [care_site_id]
      ,[care_site_name] 
      ,[location_id]
      ,[care_site_source_value] 
)
select distinct 
    care_site_id
    ,dept_name @SetNULL
    ,location_id
    ,dept_id @SetNULL
from (
    select b.[care_site_id]
        ,a.[dept_name]
        ,c.[location_id]
        ,dept_id = left(a.[dept_id],50) 
        ,ROW_NUMBER() over (partition by b.care_site_id order by b.care_site_id, a.dept_name) rn
    from stage.care_site a
    join xref.care_site_mapping b 
    on a.dept_id = b.dept_id
    left join xref.location_mapping c 
    on a.addr_key = c.addr_key
    where b.care_site_id in (
        select distinct care_site_id 
        from (
            select care_site_id from dbo.person
            union 
            select care_site_id from dbo.provider
            union 
            select care_site_id from dbo.visit_detail
            union
            select care_site_id from dbo.visit_occurrence
        ) x
    ) 
    and b.active_ind = 'Y'
) y
where rn = 1
