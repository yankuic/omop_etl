insert into dbo.care_site with (tablock)
select a.[care_site_id]
      ,[care_site_name] @SetNULL
      ,[place_of_service_concept_id]
      ,[location_id]
      ,[care_site_source_value] @SetNULL
      ,[place_of_service_source_value] @SetNULL
from xref.care_site a
join (
    select distinct care_site_id 
    from (
        select care_site_id from dbo.person
        union 
        select care_site_id from dbo.provider
        union 
        select care_site_id from dbo.visit_detail
        union
        select care_site_id from dbo.visit_occurrence
    ) b
) c 
on a.care_site_id = c.care_site_id and c.care_site_id is not null
