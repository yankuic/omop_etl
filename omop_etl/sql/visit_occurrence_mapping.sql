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

SET NOCOUNT ON;
/*
Activate only visits existing in stage table.
*/
-- update xref.visit_occurrence_mapping
-- set active_ind = 'N'
-- where active_ind = 'Y'

/*Update in batches to avoid exhausting tempdb*/
-- declare @Rows INT,
--         @BatchSize INT,
--         @Completed INT,
-- 		@Total INT,
-- 		@Message nvarchar(max)

-- set @BatchSize = 1000000
-- set @Rows = @BatchSize
-- set @Completed = 0

-- create table #batchIds (patnt_encntr_key int)

-- drop table if exists #encntr_key
-- select distinct patnt_encntr_key 
-- into #encntr_key
-- from stage.visit 

-- select @Total = @@ROWCOUNT

-- while exists (select 1 from #encntr_key)
-- begin 
-- 	delete top (@BatchSize)
--     from #encntr_key
--     output deleted.patnt_encntr_key 
-- 		into #batchIds  
	
-- 	update b 
-- 	set active_ind = 'Y'
-- 	from #batchIds a
-- 	join xref.visit_occurrence_mapping b
-- 	on a.patnt_encntr_key = b.patnt_encntr_key

-- 	set @Rows = @@ROWCOUNT
-- 	set @Completed = @Completed + @Rows

-- 	select @Message = 'Completed ' + cast(@Completed as varchar(10)) + '/' + cast(@Total as varchar(10))
--     raiserror(@Message, 0, 1) with nowait

-- 	truncate table #batchIds;
-- end

/*
Rebuild index
*/
alter index [xpk_visit_occurrence_mapping] ON [xref].[visit_occurrence_mapping] 
rebuild partition = ALL with (SORT_IN_TEMPDB = ON)

SET NOCOUNT OFF;