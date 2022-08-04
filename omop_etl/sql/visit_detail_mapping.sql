/*
Update visits in mapping visit detail table.
*/
insert into xref.visit_detail_mapping (
	patnt_encntr_key
	,visit_occurrence_id
	,load_dt
	,active_ind
)
	select patnt_encntr_key
		,visit_occurrence_id
		,load_dt = getdate()
		,active_ind = 'N'
	from (
		select distinct 
		a.patnt_encntr_key
		,c.patnt_encntr_key as primary_patnt_encntr_key
		,d.visit_occurrence_id
		from stage.visit_hospital a
		left join xref.visit_detail_mapping b on a.patnt_encntr_key = b.patnt_encntr_key
		join stage.visit_hospital c on a.hospital_account=c.hospital_account and c.primary_enc='Y'
		left join xref.visit_occurrence_mapping d on c.patnt_encntr_key=d.patnt_encntr_key
		where b.patnt_encntr_key is null
	) x


SET NOCOUNT ON;
/*
Activate only visits existing in stage table.
*/
update xref.visit_detail_mapping
set active_ind = 'N'
where active_ind = 'Y'

update b 
set active_ind = 'Y'
from stage.visit_hospital a
join xref.visit_detail_mapping b
on a.patnt_encntr_key = b.patnt_encntr_key

/*
Rebuild index
*/
alter index [xpk_visit_detail_mapping] ON [xref].[visit_detail_mapping] 
rebuild partition = ALL with (SORT_IN_TEMPDB = ON)

SET NOCOUNT OFF;