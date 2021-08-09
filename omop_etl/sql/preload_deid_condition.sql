set nocount on;

/*
Subset records where icd counts < 11 and insert into temp 
table for faster manipulation.
*/
drop table if exists #deid_diag_cd
select a.*, new_cd = diag_cd_decml
into #deid_diag_cd
from stage.condition a
join (
	select diag_cd_decml as diag_cd
	 	  ,icd_type
		  ,count(distinct patient_key) rc
	 from stage.condition
	 group by diag_cd_decml, icd_type
) b
on a.diag_cd_decml = b.diag_cd
where rc < 11

--back up stage table
--drop table if exists stage.condition_bkup 
--select * 
--into stage.condition_bkup 
--from stage.condition

--truncate table stage.condition
--insert into stage.condition with(tablock)
--select * from stage.condition_bkup

/*
Flatten ICD codes by performing the following tasks recursively.
 - Select codes with less than 11 unique patients.
 - Remove one character from the portion to the right of the decimal. 
 - Group icd codes and count patients.
 - Get codes with less than 11 unique patients.
*/
declare @MaxLen INT
set @MaxLen = (select max(len(replace(new_cd, left(new_cd, charindex('.', new_cd)), ''))) from #deid_diag_cd)

while (
	select count(*) from (
		select new_cd
			  ,icd_type
			  ,count(distinct patient_key) rc
		from #deid_diag_cd
		group by new_cd, icd_type
	) x
	where rc < 11
	and charindex('.', new_cd) > 0
) > 1
begin
	with group_icd as (
		select distinct
			 new_cd
			,icd_type 
			,right_side
			,right_side_f =reverse(stuff(reverse(right_side), 1, 1, ''))
		from (
			select new_cd
				  ,icd_type
				  ,right_side = replace(new_cd, left(new_cd, charindex('.', new_cd)), '')
				  ,count(distinct patient_key) rc
			from #deid_diag_cd
			group by new_cd, icd_type
		) x
		where rc < 11
		and charindex('.', new_cd) > 0
		and len(right_side) = @MaxLen
	)
	update a
	set a.new_cd = (
		case 
			when len(right_side_f) > 0
			then left(b.new_cd, charindex('.', b.new_cd)) + right_side_f 
			else replace(left(b.new_cd, charindex('.', b.new_cd)), '.','') 
		end
	) 
	from #deid_diag_cd a
	join group_icd b
	on a.new_cd = b.new_cd
	and a.icd_type = b.icd_type

	set @MaxLen = @MaxLen-1
end

/*
Mask codes that reached max level with less than 11 unique counts.
*/
update a 
set a.new_cd = '000'
from #deid_diag_cd a
join (
	select new_cd 
		  ,icd_type
		  ,count(distinct patient_key) rc
	from #deid_diag_cd
	group by new_cd, icd_type
	having count(distinct patient_key) < 11
) b
on a.new_cd = b.new_cd 
and a.icd_type = b.icd_type

/*
Some flattened icd codes with pattern ???.XXX or ???.?XX, where ? is an integer, don't map 
to any concept code. However, we can use non-billing ICD codes that match the pattetn ??? 
or ???.? Thus, we need to remove the Xs after the decimal. 
*/
drop table if exists #fix_cd
select new_cd
	  ,icd_type
	  ,(case
		  when patindex('%.[0-9]%', new_cd) <> 0 
		  then left(new_cd, charindex('.', new_cd) -1) + replace(right(new_cd, charindex('.', new_cd)), 'X', '')
		  when patindex('%.X%', new_cd) <> 0
		  then left(new_cd, charindex('.', new_cd) -1) + replace(right(new_cd, charindex('.', new_cd) -1), 'X', '')
		  else new_cd
	  end) new_cd_mod
	into #fix_cd
	from (
		select new_cd 
		  ,icd_type
		  ,count(distinct patient_key) rc
		from #deid_diag_cd
		group by new_cd, icd_type
	) a
	left join xref.concept b
	on a.new_cd = b.concept_code and a.icd_type + 'CM' = b.vocabulary_id
where b.concept_id is null and new_cd <> '000'

--replace new_cds with clean codes.
update a
set a.new_cd = b.new_cd_mod
from #deid_diag_cd a
join (
	select distinct 
		 new_cd
		,new_cd_mod
	from #fix_cd a
	left join xref.concept b
	on a.new_cd = b.concept_code 
	and a.icd_type + 'CM' = b.vocabulary_id
	left join xref.concept_relationship c
	on b.concept_id = c.concept_id_1 
	and c.relationship_id = 'Maps to'
) b
on a.new_cd = b.new_cd

set nocount off;

/*
Finally, replace ICD codes from stage table with modified icd codes.
*/
update a
set diag_cd_decml = new_cd
from stage.condition a
join (
	select 
		diag_cd_decml
		,new_cd 
		,icd_type
		,count(distinct patient_key) rc
	from #deid_diag_cd
	group by diag_cd_decml, new_cd, icd_type
) b
on a.diag_cd_decml = b.diag_cd_decml
and a.icd_type = b.icd_type


/* 
Verify results 
*/
--select *
--from (
--	select diag_cd_decml
--		,new_cd 
--		,icd_type
--		,count(distinct patient_key) rc
--	from #deid_diag_cd a
--	group by diag_cd_decml, new_cd, icd_type
--) a 
--join (
--	select 
--		new_cd
--		,icd_type
--		,count(distinct patient_key) rc 
--	from #deid_diag_cd
--	group by new_cd, icd_type
--) b
--on a.new_cd = b.new_cd and a.icd_type = b.icd_type
--where a.new_cd like 'C43.12%'
--order by diag_cd_decml, a.icd_type


--select distinct patient_key, diag_cd_decml, new_cd 
--from #deid_diag_cd
--where new_cd = 'C43.12'

--select distinct patient_key, diag_cd_decml 
--from stage.condition_bkup
--where diag_cd_decml like 'T84.069%'

--select 
--	new_cd
--	,icd_type
--	,count(distinct patient_key) rc 
--from #deid_diag_cd
--where new_cd = 'C43.12'
--group by new_cd, icd_type

--select 
--	diag_cd_decml
--	,icd_type
--	,count(distinct patient_key) rc 
--from stage.condition_bkup
--where diag_cd_decml like '201%'
--group by diag_cd_decml, icd_type

--clean up
--drop table if exists #fix_cd
--drop table if exists #deid_diag_cd
