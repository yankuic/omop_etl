/*
drug era
note: eras derived from drug_exposure table, using 30d gap
Script provided by OHDSI: https://ohdsi.github.io/CommonDataModel/sqlScripts.html#Era_Tables

This is a modified version to accomodate memory and/or temodb issues.
*/

drop table if exists temp.ctedrugtarget;
drop table if exists temp.rawdata;
drop table if exists temp.e2;
drop table if exists temp.e;
drop table if exists temp.cteenddates;
drop table if exists temp.ctedrugexpends;

-- normalize drug_exposure_end_date to either the existing drug exposure end date, or add days supply, or add 1 day to the start date
select a.drug_exposure_id
    ,a.person_id
    ,c.concept_id
    ,a.drug_type_concept_id
    ,drug_exposure_start_date
    ,coalesce(drug_exposure_end_date, dateadd(day, days_supply, drug_exposure_start_date), dateadd(day, 1, drug_exposure_start_date)) as drug_exposure_end_date
    ,c.concept_id as ingredient_concept_id
into temp.ctedrugtarget
from dbo.drug_exposure a
inner join xref.concept_ancestor b 
on b.descendant_concept_id = a.drug_concept_id
inner join xref.concept c 
on b.ancestor_concept_id = c.concept_id
where c.domain_id = 'drug' and c.concept_class_id = 'ingredient';

--create temp rawdata table
		select person_id
            ,ingredient_concept_id
            ,event_date
            ,event_type
            ,start_ordinal
            --enumerate person-ingredient pairs and sort records by event date and type
            ,row_number() over (partition by person_id, ingredient_concept_id order by event_date, event_type) as overall_ord 
			,ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS rowid
        into temp.rawdata
		from (
            -- select the start dates, assigning a row number to each
            select person_id
                ,ingredient_concept_id
                ,drug_exposure_start_date as event_date
                ,0 as event_type
                ,row_number() over (partition by person_id, ingredient_concept_id order by drug_exposure_start_date) as start_ordinal
            from temp.ctedrugtarget

            union all

            -- add the end dates with null as the row number, padding the end dates by 30 to allow a grace period for overlapping ranges.
            select person_id
                ,ingredient_concept_id
                ,dateadd(day, 30, drug_exposure_end_date)
                ,1 as event_type
                ,null
            from temp.ctedrugtarget
            ) rawdata

-- create temp e2 table        
		select person_id
            ,ingredient_concept_id
            ,drug_exposure_start_date as event_date
            ,row_number() over (partition by person_id, ingredient_concept_id order by drug_exposure_start_date) as start_ordinal
        into temp.e2
		from temp.ctedrugtarget

-- create temp e table
create table temp.e(
	person_id int not null,
	ingredient_concept_id int not null,
	event_date date,
	start_ordinal bigint,
	overall_ord bigint
)

DECLARE @increment integer
SET @increment = 1000000
DECLARE @rowid_max integer
SET @rowid_max = 1000000000

DECLARE @i integer
DECLARE @j integer
SET @i = 0
SET @j = @i + @increment

while @i < @rowid_max 
begin
    insert into temp.e
	select e1.person_id
        ,e1.ingredient_concept_id
        ,e1.event_date
        ,coalesce(e1.start_ordinal, max(e2.start_ordinal)) start_ordinal
        ,e1.overall_ord
	from temp.rawdata e1
    inner join temp.e2 on e1.person_id = e2.person_id
        and e1.ingredient_concept_id = e2.ingredient_concept_id
        and e2.event_date <= e1.event_date
	where e1.rowid > @i
	and e1.rowid <= @j
    group by e1.person_id, e1.ingredient_concept_id, e1.event_date, e1.start_ordinal, e1.overall_ord	

	set @i = @i + @increment
	set @j = @j + @increment
end --end of while-loop


select person_id
    ,ingredient_concept_id
    ,dateadd(day, - 30, event_date) as end_date -- unpad the end date
into temp.cteenddates
from temp.e
where 2 * e.start_ordinal - e.overall_ord = 0;


select a.person_id
    ,a.ingredient_concept_id
    ,a.drug_type_concept_id
    ,a.drug_exposure_start_date
    ,min(b.end_date) as era_end_date
into temp.ctedrugexpends
from temp.ctedrugtarget a
inner join temp.cteenddates b on a.person_id = b.person_id
    and a.ingredient_concept_id = b.ingredient_concept_id
    and b.end_date >= a.drug_exposure_start_date
group by a.person_id
    ,a.ingredient_concept_id
    ,a.drug_type_concept_id
    ,a.drug_exposure_start_date;


SET IDENTITY_INSERT dbo.drug_era ON

insert into dbo.drug_era with (tablock)(
	  [drug_era_id]
      ,[person_id]
      ,[drug_concept_id]
      ,[drug_era_start_date]
      ,[drug_era_end_date]
      ,[drug_exposure_count]
      ,[gap_days])
select row_number() OVER (
        ORDER BY person_id
        ) AS drug_era_id
	,person_id
    ,ingredient_concept_id
    ,min(drug_exposure_start_date) as drug_era_start_date
    ,era_end_date
    ,count(*) as drug_exposure_count
    ,30 as gap_days
from temp.ctedrugexpends
group by person_id, ingredient_concept_id, drug_type_concept_id, era_end_date;

SET IDENTITY_INSERT dbo.drug_era OFF


drop table if exists temp.ctedrugtarget;
drop table if exists temp.rawdata;
drop table if exists temp.e2;
drop table if exists temp.e;
drop table if exists temp.cteenddates;
drop table if exists temp.ctedrugexpends;
