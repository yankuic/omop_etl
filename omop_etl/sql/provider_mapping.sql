insert into xref.provider_mapping (
	providr_key
	,load_dt
    ,active_ind
)
select providr_key
	,load_dt = getdate()
    ,active_ind = 'N'
	from (
		select distinct
			a.providr_key
			from stage.provider a
			left join xref.provider_mapping b
			on a.providr_key = b.providr_key
		where b.providr_key is null
) x

SET NOCOUNT ON;

/*
Activate only existing in stage.provider table.
*/
update xref.provider_mapping
set active_ind = 'N'

update b 
set active_ind = 'Y'
from stage.provider a
join xref.provider_mapping b
on a.providr_key = b.providr_key

/*
Rebuild index and columnstore
*/
ALTER INDEX [xpk_provider_mapping] ON [xref].[provider_mapping] 
REBUILD PARTITION = ALL WITH (SORT_IN_TEMPDB = ON)

SET NOCOUNT OFF;
