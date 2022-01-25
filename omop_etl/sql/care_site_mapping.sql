insert into xref.care_site_mapping (
	dept_id
	,load_dt
    ,active_ind
)
select dept_id
	,load_dt = getdate()
    ,active_ind = 'N'
	from (
		select distinct
			a.dept_id
			from stage.care_site a
			left join xref.care_site_mapping b
			on a.dept_id = b.dept_id
		where b.dept_id is null
) x

SET NOCOUNT ON;

/*
Activate only existing in stage.care_site table.
*/
update xref.care_site_mapping
set active_ind = 'N'

update b 
set active_ind = 'Y'
from stage.care_site a
join xref.care_site_mapping b
on a.dept_id = b.dept_id

/*
Rebuild index and columnstore
*/
ALTER INDEX [xpk_care_site_mapping] ON [xref].[care_site_mapping] 
REBUILD PARTITION = ALL WITH (SORT_IN_TEMPDB = ON)

SET NOCOUNT OFF;
