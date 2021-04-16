set NOCOUNT on;

truncate table hipaa.person
;with shifted as (
    select a.person_id
        ,(case 
            when birth_datetime <= getdate( )-365.25*85 then '1800-01-01'
            else dateadd(day, b.date_shift, birth_datetime)
        end) [birth_datetime_deid]
        ,birth_datetime
    from dbo.person a
    join xref.person_mapping b
    on a.person_id = b.person_id
    where b.active_ind = 'Y'
)
insert into hipaa.person 
select distinct 
       a.[person_id]
      ,[gender_concept_id]
      ,[year_of_birth] = YEAR(b.{0})
      ,[month_of_birth] = MONTH(b.{0})
      ,[day_of_birth] = DAY(b.{0})
      ,[birth_datetime] = b.{0}
      ,[race_concept_id]
      ,[ethnicity_concept_id]
      ,[location_id] 
      ,[provider_id] 
      ,[care_site_id] 
      ,[person_source_value] = NULL
      ,[gender_source_value] 
      ,[gender_source_concept_id]
      ,[race_source_value]
      ,[race_source_concept_id]
      ,[ethnicity_source_value]
      ,[ethnicity_source_concept_id]
from dbo.person a
join shifted b 
on a.person_id = b.person_id


truncate table hipaa.death 
insert into hipaa.death
select a.[person_id]
      ,[death_date] = dateadd(day, @DateShift, a.death_date)
      ,[death_datetime] = dateadd(day, @DateShift, a.death_datetime)
      ,[death_type_concept_id]
      ,[cause_concept_id] 
      ,[cause_source_value]
      ,[cause_source_concept_id] 
from dbo.death a
join xref.person_mapping b
on a.person_id = b.person_id


truncate table hipaa.visit_occurrence
insert into hipaa.visit_occurrence with (tablock)
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
      ,visit_source_concept_id
      ,admitting_source_concept_id
      ,admitting_source_value
      ,discharge_to_concept_id
      ,discharge_to_source_value
      ,preceding_visit_occurrence_id 
from dbo.visit_occurrence a 
join xref.person_mapping b 
on a.person_id = b.person_id


truncate table hipaa.condition_occurrence
insert into hipaa.condition_occurrence with (tablock)
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
      ,[condition_source_concept_id]
      ,[condition_status_source_value]
      ,[condition_status_concept_id]
from [dbo].[condition_occurrence] a
join xref.person_mapping b 
on a.person_id = b.person_id 
where b.active_ind = 'Y'


truncate table hipaa.procedure_occurrence
insert into hipaa.procedure_occurrence with (tablock) 
select procedure_occurrence_id
    ,a.person_id
    ,[procedure_concept_id]
    ,[procedure_date] = dateadd(day, @DateShift, a.procedure_date)
    ,[procedure_datetime] = dateadd(day, @DateShift, a.procedure_datetime)
    ,[procedure_type_concept_id]
    ,[modifier_concept_id]
    ,[quantity]
    ,[provider_id]
    ,[visit_occurrence_id]
    ,[visit_detail_id]
    ,[procedure_source_value]
    ,[procedure_source_concept_id]
    ,[modifier_source_value]
from dbo.procedure_occurrence a 
join xref.person_mapping b
on a.person_id = b.person_id
where b.active_ind = 'Y'


truncate table hipaa.drug_exposure
insert into hipaa.drug_exposure with (tablock) 
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
      ,route_concept_id
      ,lot_number
      ,provider_id
      ,visit_occurrence_id
      ,visit_detail_id
      ,drug_source_value
      ,drug_source_concept_id
      ,route_source_value
      ,dose_unit_source_value 
from dbo.drug_exposure a 
join xref.person_mapping b
on a.person_id = b.person_id 
where b.active_ind = 'Y'


truncate table hipaa.measurement
insert into hipaa.measurement with (tablock)
select measurement_id
    ,a.person_id
    ,measurement_concept_id
    ,measurement_date = dateadd(day, @DateShift, a.measurement_date)
    ,measurement_datetime = dateadd(day, @DateShift, a.measurement_datetime)
    ,measurement_time
    ,measurement_type_concept_id
    ,operator_concept_id
    ,value_as_number
    ,value_as_concept_id
    ,unit_concept_id
    ,range_low
    ,range_high
    ,provider_id
    ,visit_occurrence_id
    ,visit_detail_id
    ,measurement_source_value
    ,measurement_source_concept_id
    ,unit_source_value
    ,value_source_value
from dbo.measurement a 
join xref.person_mapping b 
on a.person_id = b.person_id 


truncate table hipaa.observation
select distinct 
    zipcode = value_as_string
    ,(case 
        when (
                observation_source_value = 'zipcode' and (
                    --Mask 3 digit zctas with population < 20k as of 2010 US Census. Update to 2020 when data is available.
                    --Mask 3 digit zipcodes with less than 3 patients.
                    zip3 in ('036', '059', '102', '202', '203', '204', '205', '369', '556', '692', '753', '772', '821', '823', '878', '879', '884', '893') or n_patients < 3
            )
        ) then '000'
        else zip3
    end) zipcode_deid 
into #zipcode
from dbo.observation x
join (
    --Aggregate patients by 3 digit leve zipcodes. 
    select left(value_as_string,3) zip3, count(distinct person_id) n_patients
    from dbo.observation
    where observation_source_value = 'zipcode'
    group by left(value_as_string,3)
) y on left(x.value_as_string,3) = y.zip3
where observation_source_value = 'zipcode'

insert into hipaa.observation with (tablock)
select a.observation_id
    ,a.person_id
    ,[observation_concept_id]
    ,[observation_date] = dateadd(day, @DateShift, a.observation_date)
    ,[observation_datetime] = dateadd(day, @DateShift, a.observation_datetime)
    ,[observation_type_concept_id]
    ,[value_as_number]
    ,[value_as_string] = (case when observation_source_value = 'zipcode' then c.{1} else a.value_as_string end)
    ,[value_as_concept_id]
    ,[qualifier_concept_id]
    ,[unit_concept_id]
    ,[provider_id]
    ,[visit_occurrence_id]
    ,[visit_detail_id]
    ,[observation_source_value]
    ,[observation_source_concept_id]
    ,[unit_source_value]
    ,[qualifier_source_value]
from dbo.observation a
join xref.person_mapping b 
on a.person_id = b.person_id 
left join #zipcode c 
on a.value_as_string = c.zipcode 
where b.active_ind = 'Y'

drop table if exists #zipcode


truncate table hipaa.observation_period
insert into hipaa.observation_period with(tablock)
SELECT observation_period_id
	  ,a.[person_id]
      ,[observation_period_start_date] = dateadd(day,@DateShift, a.observation_period_start_date)
      ,[observation_period_end_date] = dateadd(day,@DateShift, a.observation_period_end_date)
      ,[period_type_concept_id] 
from dbo.observation_period a 
join xref.person_mapping b 
on a.person_id = b.person_id


truncate table hipaa.device_exposure
insert into hipaa.device_exposure with (tablock)
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
      ,[device_source_concept_id]
from dbo.device_exposure a 
join xref.person_mapping b
on a.person_id = b.person_id


truncate table hipaa.provider
insert into hipaa.provider with (tablock) 
select [provider_id]
      ,[provider_name] = NULL
      ,[npi] = NULL
      ,[dea] = NULL
      ,[specialty_concept_id]
      ,[care_site_id] 
      ,[year_of_birth] 
      ,[gender_concept_id]
      ,[provider_source_value] = NULL
      ,[specialty_source_value]
      ,[specialty_source_concept_id]
      ,[gender_source_value]
      ,[gender_source_concept_id]
from dbo.provider


truncate table hipaa.location
insert into hipaa.location with (tablock) 
select location_id
    ,[address_1] = NULL
    ,[address_2] = NULL
    ,[city] @SetNULL
    ,[state]
    ,[zip]
    ,[county]
    ,[location_source_value] = NULL
from dbo.location 


truncate table hipaa.care_site
insert into hipaa.care_site with (tablock)
select care_site_id
    ,care_site_name = NULL
    ,place_of_service_concept_id
    ,location_id
    ,care_site_source_value = NULL
    ,place_of_service_source_value = NULL
from dbo.care_site 

set NOCOUNT off;
