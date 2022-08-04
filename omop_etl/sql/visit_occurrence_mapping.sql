/*
Update visits in mapping table.
*/
insert into xref.visit_occurrence_mapping (
	patnt_encntr_key
	,load_dt
	,active_ind
)
	select patnt_encntr_key
		,load_dt = getdate()
		,active_ind = 'N'
	from (
		select distinct a.patnt_encntr_key
		from stage.visit a
		left join xref.visit_occurrence_mapping b
		on a.patnt_encntr_key = b.patnt_encntr_key
		where b.patnt_encntr_key is null
) x

insert into xref.visit_occurrence_mapping (
	patnt_encntr_key
	,load_dt
	,active_ind
)
	select patnt_encntr_key
		,load_dt = getdate()
		,active_ind = 'N'
	from (
		select distinct a.patnt_encntr_key
		from stage.visit_hospital a
		left join xref.visit_occurrence_mapping b
		on a.patnt_encntr_key = b.patnt_encntr_key
		where b.patnt_encntr_key is null
) x

SET NOCOUNT ON;
/*
Activate only visits existing in stage table.
*/
update xref.visit_occurrence_mapping
set active_ind = 'N'
where active_ind = 'Y'

update b 
set active_ind = 'Y'
from stage.visit_occurence a
join xref.visit_occurrence_mapping b
on a.patnt_encntr_key = b.patnt_encntr_key

/*
Rebuild index
*/
alter index [xpk_visit_occurrence_mapping] ON [xref].[visit_occurrence_mapping] 
rebuild partition = ALL with (SORT_IN_TEMPDB = ON)

SET NOCOUNT OFF;