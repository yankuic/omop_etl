/*
condition era
note: eras derived from condition_occurrence table, using 30d gap

Script provided by OHDSI: https://ohdsi.github.io/CommonDataModel/sqlScripts.html#Era_Tables
*/

drop table if exists #condition_era_phase_1;
drop table if exists #cteconditiontarget;
drop table if exists #ctecondenddates
drop table if exists #cteconditionends

-- create base eras from the concepts found in condition_occurrence
select person_id
    ,condition_concept_id
    ,condition_start_date
    ,coalesce(condition_end_date, dateadd(day, 1, condition_start_date)) as condition_end_date
into #cteconditiontarget
from dbo.condition_occurrence;

select person_id
    ,condition_concept_id 
    -- unpad the end date
    ,dateadd(day, - 30, event_date) as end_date
into #ctecondenddates
from (
    select e1.person_id
        ,e1.condition_concept_id 
        ,e1.event_date
        ,coalesce(e1.start_ordinal, max(e2.start_ordinal)) start_ordinal
        ,e1.overall_ord
    from (
        select person_id
            ,condition_concept_id
            ,event_date
            ,event_type
            ,start_ordinal
            --enumerate person-condition pairs and sort records by event date and type
            ,row_number() over (partition by person_id ,condition_concept_id order by event_date ,event_type) as overall_ord 
        from (
            select person_id
                ,condition_concept_id
                ,condition_start_date as event_date
                ,- 1 as event_type
                --enumerate person-condition pairs and sort by start_date
                ,row_number() over (partition by person_id, condition_concept_id order by condition_start_date) as start_ordinal
            from #cteconditiontarget

            union all

            -- pad the end dates by 30 to allow a grace period for overlapping ranges.
            select person_id
                ,condition_concept_id
                ,dateadd(day, 30, condition_end_date)
                ,1 as event_type
                ,null
            from #cteconditiontarget
        ) rawdata
    ) e1
    inner join (
        select person_id
            ,condition_concept_id
            ,condition_start_date as event_date
            ,row_number() over (partition by person_id, condition_concept_id order by condition_start_date) as start_ordinal
        from #cteconditiontarget
    ) e2 
    on e1.person_id = e2.person_id
    and e1.condition_concept_id = e2.condition_concept_id
    and e2.event_date <= e1.event_date
    group by e1.person_id, e1.condition_concept_id, e1.event_date, e1.start_ordinal, e1.overall_ord
) e
where (2 * e.start_ordinal) - e.overall_ord = 0;

select a.person_id
    ,a.condition_concept_id
    ,a.condition_start_date
    ,min(b.end_date) as era_end_date
into #cteconditionends
from #cteconditiontarget a
inner join #ctecondenddates b 
on a.person_id = b.person_id
and a.condition_concept_id = b.condition_concept_id
and b.end_date >= a.condition_start_date
group by a.person_id, a.condition_concept_id, a.condition_start_date;


SET IDENTITY_INSERT dbo.condition_era ON

insert into dbo.condition_era with (tablock) (
    condition_era_id
	,person_id
    ,condition_concept_id
    ,condition_era_start_date
    ,condition_era_end_date
    ,condition_occurrence_count
)
select row_number() over (
        order by person_id
       ) AS condition_era_id
	,person_id
    ,condition_concept_id
    ,min(condition_start_date) as condition_era_start_date
    ,era_end_date as condition_era_end_date
    ,count(*) as condition_occurrence_count
from #cteconditionends
group by person_id, condition_concept_id, era_end_date;

SET IDENTITY_INSERT dbo.condition_era OFF

drop table if exists #condition_era_phase_1;
drop table if exists #cteconditiontarget;
drop table if exists #ctecondenddates
drop table if exists #cteconditionends