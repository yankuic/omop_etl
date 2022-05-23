--This query modifies preload.condition_occurrence table in place.

set nocount on;

/*
Subset records where icd counts < 11 and insert into temp 
table for faster manipulation.
*/
declare @rc int = 11

drop table if exists #deid_diag_cd
select a.*
	,new_cd = condition_source_value
	,new_concept_id = NULL
into #deid_diag_cd
from preload.condition_occurrence a
join (
	select condition_source_value as diag_cd
	 	  ,icd_type
		  ,count(distinct person_id) rc
	from preload.condition_occurrence 
	group by condition_source_value, icd_type
) b
on a.condition_source_value = b.diag_cd
where rc < @rc

/*
Flatten ICD codes by performing the following tasks recursively.
 1. Calculate unique patient counts for all ICD codes.
 2. Select codes with less than 11 unique patients.
 3. Split ICD codes at decimal and extract right_side.
 4. Select codes where len(right_side) = max(len(right_sie)).
 5. On selected codes, remove one character to the right of right_side.
 6. Merge ICD codes left and right sides.
 7. Restart from step 1.
*/

--Get the max number of characters after decimal point in ICD codes
declare @MaxLen INT
set @MaxLen = (select max(len(replace(new_cd, left(new_cd, charindex('.', new_cd)), ''))) from #deid_diag_cd)

while ( 
	select count(*) from (
		select new_cd
			  ,icd_type
			  ,count(distinct person_id) rc
		from #deid_diag_cd
		group by new_cd, icd_type
	) x
	where rc < @rc
	and charindex('.', new_cd) > 0  --Ensure that we only look at the characters after the decimal point
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
				  ,count(distinct person_id) rc
			from #deid_diag_cd
			group by new_cd, icd_type
		) x
		where rc < @rc
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
set a.new_cd = '000', a.new_concept_id = 0
from #deid_diag_cd a
join (
	select new_cd 
		  ,icd_type
		  ,count(distinct person_id) rc
	from #deid_diag_cd
	group by new_cd, icd_type
	having count(distinct person_id) <= @rc
) b
on a.new_cd = b.new_cd 
and a.icd_type = b.icd_type

/*
Some flattened icd codes with pattern ???.XXX or ???.?XX, where ? is an integer, don't map 
to any concept code. However, we can use non-billing ICD codes that match the pattern ??? 
or ???.? Thus, we need to remove the Xs after the decimal. 
*/
drop table if exists #fix_cd;
select new_cd
	  ,icd_type
	  ,new_cd_mod = new_cd
into #fix_cd
from (
	select new_cd 
		,icd_type
		,count(distinct person_id) rc
	from #deid_diag_cd
	group by new_cd, icd_type
) a
left join xref.concept b
on a.new_cd = b.concept_code and a.icd_type + 'CM' = b.vocabulary_id
where b.concept_id is null and new_cd <> '000' and new_cd like '%X'

while (
	select count(*)
	from #fix_cd a
	left join xref.concept b
	on a.new_cd = b.concept_code and a.icd_type + 'CM' = b.vocabulary_id
	where b.concept_id is null and new_cd_mod like '%X'
) > 0
begin
	with icdx as (
		select new_cd	
			,icd_type 
			,right_side = replace(new_cd_mod, left(new_cd_mod, charindex('.', new_cd_mod)), '')
		from #fix_cd
	) 
	update a
		set new_cd_mod = (
			case 
				when len(right_side) > 1
					then left(a.new_cd, charindex('.', a.new_cd)) + left(right_side, len(right_side)-1)
				else replace(left(a.new_cd, charindex('.', a.new_cd)), '.','') 
			end
		)
	from #fix_cd a
	left join xref.concept b
	on a.new_cd = b.concept_code and a.icd_type + 'CM' = b.vocabulary_id
	join icdx c
	on a.new_cd = c.new_cd and a.icd_type = c.icd_type
	where b.concept_id is null and a.new_cd_mod like '%X'
end

--replace new_cds with modified codes.
update a
set a.new_cd = b.new_cd_mod
from #deid_diag_cd a
join (
	select distinct 
		 new_cd
		,new_cd_mod
	from #fix_cd
) b
on a.new_cd = b.new_cd

set nocount off;

/*
Finally, replace ICD codes from stage table with modified icd codes.
*/
update a
set condition_source_value = new_cd, condition_concept_id = isnull(d.concept_id_2, 0)
from preload.condition_occurrence a
join (
	select 
		 condition_source_value
		,new_cd 
		,icd_type
		,count(distinct person_id) rc
	from #deid_diag_cd a
	group by condition_source_value, new_cd, icd_type
) b
on a.condition_source_value = b.condition_source_value and a.icd_type = b.icd_type
left join xref.concept c
on b.new_cd = c.concept_code 
and b.icd_type + 'CM' = c.vocabulary_id
left join xref.concept_relationship d
on c.concept_id = d.concept_id_1 
and d.relationship_id = 'Maps to'
