insert into xref.location_mapping (
	addr_key
	,load_dt
    ,active_ind
)
select addr_key
	,load_dt = getdate()
    ,active_ind = 'N'
	from (
		select distinct
			a.addr_key
			from stage.location a
			left join xref.location_mapping b
			on a.addr_key = b.addr_key
		where b.addr_key is null
) x

SET NOCOUNT ON;

/*
Activate only existing in stage.location table.
*/
update xref.location_mapping
set active_ind = 'N'

update b 
set active_ind = 'Y'
from stage.location a
join xref.location_mapping b
on a.addr_key = b.addr_key

/*
Rebuild index and columnstore
*/
ALTER INDEX [xpk_location_mapping] ON [xref].[location_mapping] 
REBUILD PARTITION = ALL WITH (SORT_IN_TEMPDB = ON)

SET NOCOUNT OFF;
