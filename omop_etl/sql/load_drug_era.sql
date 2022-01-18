/*
drug era
note: eras derived from drug_exposure table, using 30d gap

Script provided by OHDSI: https://ohdsi.github.io/CommonDataModel/sqlScripts.html#Era_Tables
*/
set nocount on;

truncate table dbo.drug_era

-- normalize drug_exposure_end_date to either the existing drug exposure end date, or add days supply, or add 1 day to the start date
drop table if exists #ctedrugtarget;
select a.drug_exposure_id
    ,a.person_id
    ,c.concept_id
    ,a.drug_type_concept_id
    ,drug_exposure_start_date
    ,coalesce(drug_exposure_end_date, dateadd(day, days_supply, drug_exposure_start_date), dateadd(day, 1, drug_exposure_start_date)) as drug_exposure_end_date
    ,c.concept_id as ingredient_concept_id
into #ctedrugtarget
from dbo.drug_exposure a
inner join xref.concept_ancestor b 
on b.descendant_concept_id = a.drug_concept_id
inner join xref.concept c 
on b.ancestor_concept_id = c.concept_id
where c.domain_id = 'drug' and c.concept_class_id = 'ingredient';


declare @RowCount int = (select count(*) from #ctedrugtarget)

while @RowCount > 0
begin
	begin transaction

	drop table if exists #cteenddates;
	drop table if exists #ctedrugexpends;
	drop table if exists #top1e6_ctedrugtarget

	select *
	into #top1e6_ctedrugtarget
	from #ctedrugtarget
	where person_id in (select distinct top 10000 person_id from #ctedrugtarget)


	select person_id
		,ingredient_concept_id
		,dateadd(day, - 30, event_date) as end_date -- unpad the end date
	into #cteenddates
	from (
		select e1.person_id
			,e1.ingredient_concept_id
			,e1.event_date
			,coalesce(e1.start_ordinal, max(e2.start_ordinal)) start_ordinal
			,e1.overall_ord
		from (
			select person_id
				,ingredient_concept_id
				,event_date
				,event_type
				,start_ordinal
				--enumerate person-ingredient pairs and sort records by event date and type
				,row_number() over (partition by person_id, ingredient_concept_id order by event_date, event_type) as overall_ord 
			from (
				-- select the start dates, assigning a row number to each
				select person_id
					,ingredient_concept_id
					,drug_exposure_start_date as event_date
					,0 as event_type
					,row_number() over (partition by person_id, ingredient_concept_id order by drug_exposure_start_date) as start_ordinal
				from #top1e6_ctedrugtarget

				union all

				-- add the end dates with null as the row number, padding the end dates by 30 to allow a grace period for overlapping ranges.
				select person_id
					,ingredient_concept_id
					,dateadd(day, 30, drug_exposure_end_date)
					,1 as event_type
					,null
				from #top1e6_ctedrugtarget
				) rawdata
			) e1
		inner join (
			select person_id
				,ingredient_concept_id
				,drug_exposure_start_date as event_date
				,row_number() over (partition by person_id, ingredient_concept_id order by drug_exposure_start_date) as start_ordinal
			from #top1e6_ctedrugtarget
		) e2 
		on e1.person_id = e2.person_id
		and e1.ingredient_concept_id = e2.ingredient_concept_id
		and e2.event_date <= e1.event_date
		group by e1.person_id, e1.ingredient_concept_id, e1.event_date, e1.start_ordinal, e1.overall_ord
		) e
	where 2 * e.start_ordinal - e.overall_ord = 0
	

	select a.person_id
		,a.ingredient_concept_id
		,a.drug_type_concept_id
		,a.drug_exposure_start_date
		,min(b.end_date) as era_end_date
	into #ctedrugexpends
	from #top1e6_ctedrugtarget a
	inner join #cteenddates b on a.person_id = b.person_id
		and a.ingredient_concept_id = b.ingredient_concept_id
		and b.end_date >= a.drug_exposure_start_date
	group by a.person_id
		,a.ingredient_concept_id
		,a.drug_type_concept_id
		,a.drug_exposure_start_date;

	set nocount off; 
	
	
	insert into dbo.drug_era with (tablock)
	select person_id
		,ingredient_concept_id
		,min(drug_exposure_start_date) as drug_era_start_date
		,era_end_date
		,count(*) as drug_exposure_count
		,30 as gap_days
	from #ctedrugexpends
	group by person_id, ingredient_concept_id, drug_type_concept_id, era_end_date;


	delete a 
	from #ctedrugtarget a
	inner join #top1e6_ctedrugtarget b
	on a.drug_exposure_id = b.drug_exposure_id and a.person_id = b.person_id


	commit transaction
	set @RowCount = (select count(*) from #ctedrugtarget)
END
