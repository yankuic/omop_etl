--@DateShift is being set in load.py --> load_hippa method
--@SetNULL is being set in load.py --> load_hippa method

set NOCOUNT on;

drop table if exists hipaa.person
;with shifted as (
    select a.person_id
        ,(case 
            when birth_datetime <= convert(date, getdate()-365.25*85) then '1800-01-01'
            else dateadd(day, b.date_shift, birth_datetime)
        end) [birth_datetime_deid]
        ,birth_datetime
    from dbo.person a
    join xref.person_mapping b
    on a.person_id = b.person_id
    where b.active_ind = 'Y'
),
race_count as (
	select 
		a.person_id
		,a.race_concept_id
		,a.race_source_value
		,(case 
			when rc < 11 then 0 
			else a.race_concept_id
		 end) race_concept_id_deid
		,(case
			when rc < 11 then 'UNKNOWN'
			else a.race_source_value
		 end) race_source_value_deid
	from dbo.person a
	join (
		select race_source_value
			,count(distinct a.person_id) rc
		from dbo.person a
		join xref.person_mapping b
		on a.person_id = b.person_id
		where b.active_ind = 'Y'
		group by race_source_value
	) b
	on a.race_source_value = b.race_source_value
),
ethnicity_count as(
	select 
		a.person_id
		,a.ethnicity_concept_id
		,a.ethnicity_source_value
		,(case 
			when rc < 11 then 0 
			else a.ethnicity_concept_id
		 end) ethnicity_concept_id_deid
		,(case
			when rc < 11 then 'UNKNOWN'
			else a.ethnicity_source_value
		 end) ethnicity_source_value_deid
	from dbo.person a
	join (
		select ethnicity_source_value
			,count(distinct a.person_id) rc
		from dbo.person a
		join xref.person_mapping b
		on a.person_id = b.person_id
		where b.active_ind = 'Y'
		group by ethnicity_source_value
	) b
	on a.ethnicity_source_value = b.ethnicity_source_value
)
--The placeholder values in this query are being filled by variables listed in load.py --> load_hipaa method
select distinct 
       a.person_id
      ,[gender_concept_id] = isnull(gender_concept_id, 0)
      ,[year_of_birth] = YEAR(b.{0})
      ,[month_of_birth] = MONTH(b.{0})
      ,[day_of_birth] = DAY(b.{0})
      ,[birth_datetime] = b.{0}
      ,[race_concept_id] = isnull(c.{1}, 0)
      ,[ethnicity_concept_id] = isnull(d.{2}, 0)
      ,[location_id] 
      ,[provider_id] 
      ,[care_site_id] 
      ,[person_source_value] = NULL
      ,[gender_source_value] 
      ,[gender_source_concept_id] = isnull(gender_source_concept_id, 0)
      ,[race_source_value] = c.{3}
      ,[race_source_concept_id] = isnull(race_source_concept_id, 0)
      ,[ethnicity_source_value] = d.{4}
      ,[ethnicity_source_concept_id] = isnull(ethnicity_source_concept_id, 0)
into hipaa.person 
from dbo.person a
join shifted b 
on a.person_id = b.person_id
join race_count c 
on a.person_id = c.person_id 
join ethnicity_count d 
on a.person_id = d.person_id


drop table if exists hipaa.death 
select a.[person_id]
      ,[death_date] = dateadd(day, @DateShift, a.death_date)
      ,[death_datetime] = dateadd(day, @DateShift, a.death_datetime)
      ,[death_type_concept_id] = isnull(death_type_concept_id, 0)
      ,[cause_concept_id]  = isnull(cause_concept_id, 0)
      ,[cause_source_value]
      ,[cause_source_concept_id] = isnull(cause_source_concept_id, 0)
into hipaa.death
from dbo.death a
join xref.person_mapping b
on a.person_id = b.person_id
where b.active_ind = 'Y'


drop table if exists hipaa.visit_occurrence
select visit_occurrence_id 
      ,a.person_id 
      ,visit_concept_id
      ,visit_start_date = dateadd(day, @DateShift, a.visit_start_date)
      ,visit_start_datetime = dateadd(day, @DateShift, a.visit_start_datetime)
      ,visit_end_date = dateadd(day, @DateShift, a.visit_end_date)
      ,visit_end_datetime = dateadd(day, @DateShift, a.visit_end_datetime)
      ,visit_type_concept_id
      ,provider_id
      ,care_site_id 
      ,visit_source_value
      ,visit_source_concept_id = isnull(visit_source_concept_id, 0)
      ,admitting_source_concept_id = isnull(admitting_source_concept_id, 0)
      ,admitting_source_value
      ,discharge_to_concept_id = isnull(discharge_to_concept_id, 0)
      ,discharge_to_source_value
      ,preceding_visit_occurrence_id
into hipaa.visit_occurrence
from dbo.visit_occurrence a 
join xref.person_mapping b 
on a.person_id = b.person_id
where b.active_ind = 'Y'


drop table if exists hipaa.visit_detail
select visit_detail_id 
      ,a.person_id 
      ,visit_detail_concept_id
      ,visit_detail_start_date = dateadd(day, @DateShift, a.visit_detail_start_date)
      ,visit_detail_start_datetime = dateadd(day, @DateShift, a.visit_detail_start_datetime)
      ,visit_detail_end_date = dateadd(day, @DateShift, a.visit_detail_end_date)
      ,visit_detail_end_datetime = dateadd(day, @DateShift, a.visit_detail_end_datetime)
      ,visit_detail_type_concept_id
      ,provider_id
      ,care_site_id 
      ,visit_detail_source_value
      ,visit_detail_source_concept_id = isnull(visit_detail_source_concept_id, 0)
	  ,admitting_source_value
      ,admitting_source_concept_id = isnull(admitting_source_concept_id, 0)
	  ,discharge_to_source_value
      ,discharge_to_concept_id = isnull(discharge_to_concept_id, 0)
      ,preceding_visit_detail_id
	  ,visit_detail_parent_id
	  ,visit_occurrence_id
into hipaa.visit_detail
from dbo.visit_detail a 
join xref.person_mapping b 
on a.person_id = b.person_id
where b.active_ind = 'Y'


drop table if exists hipaa.condition_occurrence
select [condition_occurrence_id]
      ,a.person_id
      ,[condition_concept_id]
      ,condition_start_date = dateadd(day, @DateShift, a.condition_start_date)
      ,condition_start_datetime = dateadd(day, @DateShift, a.condition_start_datetime)
      ,condition_end_date = dateadd(day, @DateShift, a.condition_end_date)
      ,condition_end_datetime = dateadd(day, @DateShift, a.condition_end_datetime)
      ,[condition_type_concept_id]
      ,[stop_reason]
      ,[provider_id]
      ,[visit_occurrence_id]
      ,[visit_detail_id]
      ,[condition_source_value]
      ,condition_source_concept_id = isnull(condition_source_concept_id, 0)
      ,[condition_status_source_value]
      ,condition_status_concept_id = isnull(condition_status_concept_id, 0)
into hipaa.condition_occurrence
from [dbo].[condition_occurrence] a
join xref.person_mapping b 
on a.person_id = b.person_id 
where b.active_ind = 'Y'


drop table if exists hipaa.procedure_occurrence
select procedure_occurrence_id
    ,a.person_id
    ,[procedure_concept_id]
    ,[procedure_date] = dateadd(day, @DateShift, a.procedure_date)
    ,[procedure_datetime] = dateadd(day, @DateShift, a.procedure_datetime)
    ,[procedure_type_concept_id]
    ,[modifier_concept_id] = isnull(modifier_concept_id, 0)
    ,[quantity]
    ,[provider_id]
    ,[visit_occurrence_id]
    ,[visit_detail_id]
    ,[procedure_source_value]
    ,[procedure_source_concept_id] = isnull(procedure_source_concept_id, 0)
    ,[modifier_source_value]
into hipaa.procedure_occurrence
from dbo.procedure_occurrence a 
join xref.person_mapping b
on a.person_id = b.person_id
where b.active_ind = 'Y'


drop table if exists hipaa.drug_exposure
select drug_exposure_id 
      ,a.person_id
      ,drug_concept_id
      ,drug_exposure_start_date = dateadd(day, @DateShift, a.drug_exposure_start_date)
      ,drug_exposure_start_datetime = dateadd(day, @DateShift, a.drug_exposure_start_datetime)
      ,drug_exposure_end_date = dateadd(day, @DateShift, a.drug_exposure_end_date)
      ,drug_exposure_end_datetime = dateadd(day, @DateShift, a.drug_exposure_end_datetime)
      ,verbatim_end_date = dateadd(day, @DateShift, a.verbatim_end_date)
      ,drug_type_concept_id
      ,stop_reason
      ,refills
      ,quantity
      ,days_supply
      ,sig
      ,route_concept_id = isnull(route_concept_id, 0)
      ,lot_number
      ,provider_id
      ,visit_occurrence_id
      ,visit_detail_id
      ,drug_source_value
      ,drug_source_concept_id = isnull(drug_source_concept_id, 0)
      ,route_source_value
      ,dose_unit_source_value 
into hipaa.drug_exposure
from dbo.drug_exposure a 
join xref.person_mapping b
on a.person_id = b.person_id 
where b.active_ind = 'Y'


drop table if exists hipaa.measurement
select measurement_id
    ,a.person_id
    ,measurement_concept_id
    ,measurement_date = dateadd(day, @DateShift, a.measurement_date)
    ,measurement_datetime = dateadd(day, @DateShift, a.measurement_datetime)
    ,measurement_time
    ,measurement_type_concept_id
    ,operator_concept_id = isnull(operator_concept_id, 0)
    ,value_as_number
    ,value_as_concept_id = isnull(value_as_concept_id, 0)
    ,unit_concept_id = isnull(unit_concept_id, 0)
    ,range_low
    ,range_high
    ,provider_id
    ,visit_occurrence_id
    ,visit_detail_id
    ,measurement_source_value
    ,measurement_source_concept_id = isnull(measurement_source_concept_id, 0)
    ,unit_source_value
    ,value_source_value
into hipaa.measurement
from dbo.measurement a 
join xref.person_mapping b 
on a.person_id = b.person_id 
where b.active_ind = 'Y'


drop table if exists hipaa.observation
drop table if exists #zipcode
select distinct 
    zipcode = value_as_string
    ,(case 
        when (
                observation_source_value = 'zipcode' and (
                    --TODO: Update with 2020 census data if available.
                    --Mask 3 digit zctas with population < 20k as of 2010 US Census. 
                    --Mask 3 digit zipcodes with less than 11 patients.
                    zip3 in ('036', '059', '102', '202', '203', '204', '205', '369', '556', '692', '753', '772', '821', '823', '878', '879', '884', '893') 
					or n_patients < 11
               )    
        ) then '000'
        else zip3
    end) zipcode_deid 
into #zipcode
from dbo.observation x
join (
    --Aggregate patients by 3 digit level zipcodes. 
    select left(value_as_string,3) zip3, count(distinct person_id) n_patients
    from dbo.observation
    where observation_source_value = 'zipcode'
    group by left(value_as_string, 3)
) y on left(x.value_as_string,3) = y.zip3
where observation_source_value = 'zipcode'


--The placeholder value in this query are being filled by variables listed in load.py --> load_hipaa method
select a.observation_id
    ,a.person_id
    ,observation_concept_id = isnull(observation_concept_id, 0)
    ,[observation_date] = dateadd(day, @DateShift, a.observation_date)
    ,[observation_datetime] = dateadd(day, @DateShift, a.observation_datetime)
    ,observation_type_concept_id = isnull(observation_type_concept_id, 0)
    ,[value_as_number]
    ,[value_as_string] = (case when observation_source_value = 'zipcode' then c.{5} else a.value_as_string end)
    ,value_as_concept_id = isnull(value_as_concept_id, 0)
    ,qualifier_concept_id = isnull(qualifier_concept_id, 0)
    ,unit_concept_id = isnull(unit_concept_id, 0)
    ,[provider_id]
    ,[visit_occurrence_id]
    ,[visit_detail_id]
    ,[observation_source_value]
    ,observation_source_concept_id = isnull([observation_source_concept_id], 0)
    ,[unit_source_value]
    ,[qualifier_source_value]
into hipaa.observation
from dbo.observation a
join xref.person_mapping b 
on a.person_id = b.person_id 
left join #zipcode c 
on a.value_as_string = c.zipcode 
where b.active_ind = 'Y'

drop table if exists #zipcode


drop table if exists hipaa.observation_period
SELECT observation_period_id
	  ,a.[person_id]
      ,[observation_period_start_date] = dateadd(day,@DateShift, a.observation_period_start_date)
      ,[observation_period_end_date] = dateadd(day,@DateShift, a.observation_period_end_date)
      ,[period_type_concept_id]
into hipaa.observation_period 
from dbo.observation_period a 
join xref.person_mapping b 
on a.person_id = b.person_id
where b.active_ind = 'Y'


drop table if exists hipaa.device_exposure
select device_exposure_id
      ,a.person_id
      ,[device_concept_id]
      ,[device_exposure_start_date] = dateadd(day, @DateShift, a.device_exposure_start_date)
      ,[device_exposure_start_datetime] = dateadd(day, @DateShift, a.device_exposure_start_datetime)
      ,[device_exposure_end_date] = dateadd(day, @DateShift, a.device_exposure_end_date)
      ,[device_exposure_end_datetime] = dateadd(day, @DateShift, a.device_exposure_end_datetime)
      ,[device_type_concept_id]
      ,[unique_device_id]
      ,[quantity]
      ,[provider_id]
      ,[visit_occurrence_id]
      ,[visit_detail_id]
      ,[device_source_value]
      ,[device_source_concept_id] = isnull(device_source_concept_id, 0)
into hipaa.device_exposure 
from dbo.device_exposure a 
join xref.person_mapping b
on a.person_id = b.person_id
where b.active_ind = 'Y'


drop table if exists hipaa.provider
select [provider_id]
      ,[provider_name] = NULL
      ,[npi] = NULL
      ,[dea] = NULL
      ,[specialty_concept_id] = isnull(specialty_concept_id, 0)
      ,[care_site_id] 
      ,[year_of_birth] @SetNULL
      ,[gender_concept_id] = coalesce(@SetZero, gender_concept_id, 0)
      ,[provider_source_value] = NULL
      ,[specialty_source_value]
      ,[specialty_source_concept_id] = coalesce(@SetZero, specialty_source_concept_id)
      ,[gender_source_value] @SetNULL
      ,[gender_source_concept_id] = coalesce(@SetZero, gender_source_concept_id, 0)
into hipaa.provider
from dbo.provider


drop table if exists hipaa.location
drop table if exists #location_zipcode
select distinct 
    zipcode = zip
    ,(case 
        when (
            --TODO: Update with 2020 census data if available.
            --Mask 3 digit zctas with population < 20k as of 2010 US Census. 
            --Mask 3 digit zipcodes with less than 11 patients.
            zip3 in ('036', '059', '102', '202', '203', '204', '205', '369', '556', '692', '753', '772', '821', '823', '878', '879', '884', '893') 
			or n_patients < 11
        ) then '000'
        else zip3
    end) zipcode_deid 
into #location_zipcode
from dbo.location x
join (
    --Aggregate patients by 3 digit level zipcodes. 
    select left(zip, 3) zip3, count(distinct person_id) n_patients
    from dbo.location a 
    join dbo.person b 
    on a.location_id = b.location_id
    group by left(zip, 3)
) y on left(x.zip, 3) = y.zip3

--The placeholder value in this query are being filled by variables listed in load.py --> load_hipaa method
select location_id
    ,[address_1] = NULL
    ,[address_2] = NULL
    ,[city] @SetNULL
    ,[state]
    ,[zip] = b.{6}
    ,[county] @SetNULL
    ,[location_source_value] = NULL
into hipaa.location
from dbo.location a
join #location_zipcode b 
on a.zip = b.zipcode

drop table if exists #location_zipcode


drop table if exists hipaa.care_site
select care_site_id
    ,care_site_name = NULL
    ,place_of_service_concept_id = isnull(place_of_service_concept_id, 0)
    ,location_id
    ,care_site_source_value = NULL
    ,place_of_service_source_value = NULL
into hipaa.care_site
from dbo.care_site 


drop table if exists hipaa.condition_era
select condition_era_id
      ,a.person_id
      ,condition_concept_id
      ,condition_era_start_date = dateadd(day, @DateShift, a.condition_era_start_date)
      ,condition_era_end_date = dateadd(day, @DateShift, a.condition_era_end_date)
      ,condition_occurrence_count
into hipaa.condition_era
from dbo.condition_era a
join xref.person_mapping b
on a.person_id = b.person_id
where b.active_ind = 'Y'


drop table if exists hipaa.drug_era
select drug_era_id
      ,a.person_id
      ,drug_concept_id
      ,drug_era_start_date = dateadd(day, @DateShift, a.drug_era_start_date)
      ,drug_era_end_date = dateadd(day, @DateShift, a.drug_era_end_date)
      ,drug_exposure_count
      ,gap_days
into hipaa.drug_era 
from dbo.drug_era a 
join xref.person_mapping b
on a.person_id = b.person_id
where b.active_ind = 'Y'

set NOCOUNT off;
