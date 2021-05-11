/* Move records by domain */
SET NOCOUNT ON;

/* Measurement -> observation*/
insert into dbo.observation with(tablock) (
	[person_id]
	,[observation_concept_id]
	,[observation_date]
	,[observation_datetime]
	,[observation_type_concept_id]
	,[value_as_number]
	,[value_as_string]
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
)
select person_id
	,observation_concept_id = a.measurement_concept_id
	,observation_date = a.measurement_date
	,observation_datetime = a.measurement_datetime
	,observation_type_concept_id = a.measurement_type_concept_id
	,value_as_number = a.value_as_number
	,value_as_string = NULL
	,value_as_concept_id = a.value_as_concept_id
	,qualifier_concept_id = NULL
	,unit_concept_id = a.unit_concept_id
	,provider_id = a.provider_id
	,visit_occurrence_id = a.visit_occurrence_id
	,visit_detail_id = NULL
	,observation_source_value = a.measurement_source_value
	,observation_source_concept_id = a.measurement_source_concept_id
	,unit_source_value = a.unit_source_value
	,qualifier_source_value = NULL
FROM dbo.measurement a
join xref.concept b
on a.measurement_concept_id = b.concept_id
where b.domain_id = 'Observation'

delete a
from dbo.measurement a
join xref.concept b
on a.measurement_concept_id = b.concept_id
where b.domain_id = 'Observation';
GO

/*Procedure -> Measurement*/
insert into dbo.measurement with(tablock) (
	[person_id]
	,[measurement_concept_id]
	,[measurement_date]
	,[measurement_datetime]
	,[measurement_time]
	,[measurement_type_concept_id]
	,[operator_concept_id]
	,[value_as_number]
	,[value_as_concept_id]
	,[unit_concept_id]
	,[range_low]
	,[range_high]
	,[provider_id]
	,[visit_occurrence_id]
	,[visit_detail_id]
	,[measurement_source_value]
	,[measurement_source_concept_id]
	,[unit_source_value]
	,[value_source_value]
)
select person_id 
	,measurement_concept_id = a.procedure_concept_id
	,measurement_date = a.procedure_date
	,measurement_datetime = a.procedure_datetime
	,measurement_time = cast(a.procedure_datetime as time)
	,measurement_type_concept_id = a.procedure_type_concept_id
	,operator_concept_id = NULL
	,value_as_number = NULL
	,value_as_concept_id = NULL
	,unit_concept_id = NULL
	,range_low = NULL
	,range_high = NULL
	,provider_id = a.provider_id
	,visit_occurrence_id = a.visit_occurrence_id
	,visit_detail_id
	,measurement_source_value = a.procedure_source_value
	,measurement_source_concept_id = a.procedure_source_concept_id
	,unit_source_value = NULL
	,value_source_value = NULL
from dbo.procedure_occurrence a
join xref.concept b
on a.procedure_concept_id = b.concept_id
where b.domain_id = 'Measurement'

delete a
from dbo.procedure_occurrence a
join xref.concept b
on a.procedure_concept_id = b.concept_id
where b.domain_id = 'Measurement';
GO

/* Procedure occurrence -> Observation*/
insert into dbo.observation with(tablock) (
	[person_id]
	,[observation_concept_id]
	,[observation_date]
	,[observation_datetime]
	,[observation_type_concept_id]
	,[value_as_number]
	,[value_as_string]
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
)
select person_id
	,observation_concept_id = a.procedure_concept_id
	,observation_date = a.procedure_date
	,observation_datetime = a.procedure_datetime
	,observation_type_concept_id = a.procedure_type_concept_id
	,value_as_number = a.quantity
	,value_as_string = NULL
	,value_as_concept_id = NULL
	,qualifier_concept_id = NULL
	,unit_concept_id = NULL
	,provider_id = a.provider_id
	,visit_occurrence_id = a.visit_occurrence_id
	,visit_detail_id
	,observation_source_value = a.procedure_source_value
	,observation_source_concept_id = a.procedure_source_concept_id
	,unit_source_value = NULL
	,qualifier_source_value = NULL
from dbo.procedure_occurrence a
join xref.concept b
on a.procedure_concept_id = b.concept_id
where b.domain_id = 'Observation'

delete a
from dbo.procedure_occurrence a
join xref.concept b
on a.procedure_concept_id = b.concept_id
where b.domain_id = 'Observation';
GO

/*Procedure occurrence -> Drug exposure*/
insert into dbo.drug_exposure with(tablock) (
	[person_id]
	,[drug_concept_id]
	,[drug_exposure_start_date]
	,[drug_exposure_start_datetime]
	,[drug_exposure_end_date]
	,[drug_exposure_end_datetime]
	,[verbatim_end_date]
	,[drug_type_concept_id]
	,[stop_reason]
	,[refills]
	,[quantity]
	,[days_supply]
	,[sig]
	,[route_concept_id]
	,[lot_number]
	,[provider_id]
	,[visit_occurrence_id]
	,[visit_detail_id]
	,[drug_source_value]
	,[drug_source_concept_id]
	,[route_source_value]
	,[dose_unit_source_value]
)
select person_id
      ,drug_concept_id = a.procedure_concept_id
      ,drug_exposure_start_date = a.procedure_date
      ,drug_exposure_start_datetime = a.procedure_datetime
      ,drug_exposure_end_date = a.procedure_date
      ,drug_exposure_end_datetime = a.procedure_datetime
      ,verbatim_end_date = NULL
      ,drug_type_concept_id = a.procedure_type_concept_id
      ,stop_reason = NULL
      ,refills = NULL
      ,quantity = NULL
      ,days_supply = NULL
      ,sig = NULL
      ,route_concept_id = NULL
      ,lot_number = NULL
      ,provider_id = a.provider_id
      ,visit_occurrence_id = a.visit_occurrence_id
      ,visit_detail_id = NULL
      ,drug_source_value = a.procedure_source_value
      ,drug_source_concept_id = a.procedure_source_concept_id
      ,route_source_value = NULL
      ,dose_unit_source_value = NULL
from dbo.procedure_occurrence a 
join xref.concept b 
on a.procedure_concept_id = b.concept_id
where b.domain_id = 'Drug'

delete a
from dbo.procedure_occurrence a 
join xref.concept b 
on a.procedure_concept_id = b.concept_id
where b.domain_id = 'Drug';
GO

/*Procedure occurrence -> Device exposure*/
insert into dbo.device_exposure with(tablock) (
       [person_id]
      ,[device_concept_id]
      ,[device_exposure_start_date]
      ,[device_exposure_start_datetime]
      ,[device_exposure_end_date]
      ,[device_exposure_end_datetime]
      ,[device_type_concept_id]
      ,[unique_device_id]
      ,[quantity]
      ,[provider_id]
      ,[visit_occurrence_id]
      ,[visit_detail_id]
      ,[device_source_value]
      ,[device_source_concept_id]
)
select person_id = a.person_id
      ,device_concept_id = a.procedure_concept_id
      ,device_exposure_start_date = a.procedure_date
      ,device_exposure_start_datetime = a.procedure_datetime
      ,device_exposure_end_date = NULL
      ,device_exposure_end_datetime = NULL
      ,device_type_concept_id = a.procedure_type_concept_id
      ,unique_device_id = NULL
      ,quantity = a.quantity
      ,provider_id = a.provider_id
      ,visit_occurrence_id = a.visit_occurrence_id
      ,visit_detail_id = NULL
      ,device_source_value = a.procedure_source_value
      ,device_source_concept_id = a.procedure_source_concept_id
from dbo.procedure_occurrence a 
join xref.concept b 
on a.procedure_concept_id = b.concept_id 
where b.domain_id = 'Device'

delete a
from dbo.procedure_occurrence a 
join xref.concept b 
on a.procedure_concept_id = b.concept_id 
where b.domain_id = 'Device';
GO

/*Observation -> Measurement*/
insert into dbo.measurement with(tablock)(
	[person_id]
	,[measurement_concept_id]
	,[measurement_date]
	,[measurement_datetime]
	,[measurement_time]
	,[measurement_type_concept_id]
	,[operator_concept_id]
	,[value_as_number]
	,[value_as_concept_id]
	,[unit_concept_id]
	,[range_low]
	,[range_high]
	,[provider_id]
	,[visit_occurrence_id]
	,[visit_detail_id]
	,[measurement_source_value]
	,[measurement_source_concept_id]
	,[unit_source_value]
	,[value_source_value]
)
select person_id
	,measurement_concept_id = a.observation_concept_id
	,measurement_date = a.observation_date
	,measurement_datetime = a.observation_datetime
	,measurement_time = cast(a.observation_datetime as time)
	,measurement_type_concept_id = a.observation_type_concept_id
	,operator_concept_id = NULL
	,value_as_number  
	,value_as_concept_id
	,unit_concept_id
	,range_low = NULL
	,range_high = NULL
	,provider_id = a.provider_id
	,visit_occurrence_id = a.visit_occurrence_id
	,visit_detail_id
	,measurement_source_value = a.observation_source_value
	,measurement_source_concept_id = a.observation_source_concept_id
	,unit_source_value = NULL
	,value_source_value = a.value_as_string
from dbo.observation a
join xref.concept b
on a.observation_concept_id = b.concept_id
where b.domain_id = 'Measurement'

delete a
from dbo.observation a
join xref.concept b
on a.observation_concept_id = b.concept_id
where b.domain_id = 'Measurement';
GO

/*Observation -> Condition occurrence*/
insert into dbo.condition_occurrence with(tablock)(
	[person_id]
	,[condition_concept_id]
	,[condition_start_date]
	,[condition_start_datetime]
	,[condition_end_date]
	,[condition_end_datetime]
	,[condition_type_concept_id]
	,[stop_reason]
	,[provider_id]
	,[visit_occurrence_id]
	,[visit_detail_id]
	,[condition_source_value]
	,[condition_source_concept_id]
	,[condition_status_source_value]
	,[condition_status_concept_id]
)
select person_id
	,condition_concept_id = a.observation_concept_id
	,condition_start_date = a.observation_date
	,condition_start_datetime = a.observation_datetime
	,condition_end_date = NULL
	,condition_end_datetime = NULL
	,condition_type_concept_id = a.observation_type_concept_id
	,stop_reason = NULL
	,provider_id = a.provider_id
	,visit_occurrence_id = a.visit_occurrence_id
	,visit_detail_id = NULL
	,condition_source_value = a.observation_source_value
	,condition_source_concept_id = a.observation_source_concept_id
	,condition_status_source_value = NULL
	,condition_status_concept_id = NULL
 FROM dbo.observation a
 join xref.concept b
 on a.observation_concept_id = b.concept_id
where b.domain_id = 'Condition'

delete a
from dbo.observation a
join xref.concept b
on a.observation_concept_id = b.concept_id
where b.domain_id = 'Condition';
GO

/*Condition occurrence -> Measurement*/
insert into dbo.measurement with(tablock)(
	[person_id]
	,[measurement_concept_id]
	,[measurement_date]
	,[measurement_datetime]
	,[measurement_time]
	,[measurement_type_concept_id]
	,[operator_concept_id]
	,[value_as_number]
	,[value_as_concept_id]
	,[unit_concept_id]
	,[range_low]
	,[range_high]
	,[provider_id]
	,[visit_occurrence_id]
	,[visit_detail_id]
	,[measurement_source_value]
	,[measurement_source_concept_id]
	,[unit_source_value]
	,[value_source_value]
)
select person_id
	,measurement_concept_id = a.condition_concept_id
	,measurement_date = a.condition_start_date
	,measurement_datetime = a.condition_start_datetime
	,measurement_time = cast(a.condition_start_datetime as time)
	,measurement_type_concept_id = 32817
	,operator_concept_id = NULL 
	,value_as_number = NULL
	,value_as_concept_id = NULL
	,unit_concept_id = NULL
	,range_low = NULL
	,range_high = NULL
	,provider_id = a.provider_id
	,visit_occurrence_id = a.visit_occurrence_id
	,visit_detail_id = NULL
	,measurement_source_value = a.condition_source_value
	,measurement_source_concept_id = a.condition_source_concept_id
	,unit_source_value = NULL
	,value_source_value = NULL
from dbo.condition_occurrence a
 join xref.concept b
 on a.condition_concept_id = b.concept_id
where b.domain_id = 'Measurement'

delete a
from dbo.condition_occurrence a
join xref.concept b
on a.condition_concept_id = b.concept_id
where b.domain_id = 'Measurement';
GO

/*Condition occurrence -> Observation*/
insert into dbo.observation with(tablock)(
	[person_id]
	,[observation_concept_id]
	,[observation_date]
	,[observation_datetime]
	,[observation_type_concept_id]
	,[value_as_number]
	,[value_as_string]
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
)
select person_id
	,observation_concept_id = a.condition_concept_id
	,observation_date = a.condition_start_date
	,observation_datetime = a.condition_start_datetime
	,observation_type_concept_id = a.condition_type_concept_id
	,value_as_number = NULL
	,value_as_string = NULL
	,value_as_concept_id = NULL
	,qualifier_concept_id = NULL
	,unit_concept_id = NULL
	,provider_id = a.provider_id
	,visit_occurrence_id = a.visit_occurrence_id
	,visit_detail_id = NULL
	,observation_source_value = a.condition_source_value
	,observation_source_concept_id = a.condition_source_concept_id
	,unit_source_value = NULL
	,qualifier_source_value = NULL
 FROM dbo.condition_occurrence a
 join xref.concept b
 on a.condition_concept_id = b.concept_id
where b.domain_id = 'Observation'

delete a
from dbo.condition_occurrence a
join xref.concept b
on a.condition_concept_id = b.concept_id
where b.domain_id = 'Observation';
GO

/*Condition occurrence -> Procedure occurrence*/
insert into dbo.procedure_occurrence with(tablock)(
	[person_id]
	,[procedure_concept_id]
	,[procedure_date]
	,[procedure_datetime]
	,[procedure_type_concept_id]
	,[modifier_concept_id]
	,[quantity]
	,[provider_id]
	,[visit_occurrence_id]
	,[visit_detail_id]
	,[procedure_source_value]
	,[procedure_source_concept_id]
	,[modifier_source_value]
)
select person_id
	,procedure_concept_id = a.condition_concept_id
	,procedure_date = a.condition_start_date
	,procedure_datetime = a.condition_start_datetime
	,procedure_type_concept_id = a.condition_type_concept_id
	,modifier_concept_id = NULL
	,quantity = NULL
	,provider_id = a.provider_id
	,visit_occurrence_id = a.visit_occurrence_id
	,visit_detail_id = NULL
	,procedure_source_value = a.condition_source_value
	,procedure_source_concept_id = a.condition_source_concept_id
	,modifier_source_value = NULL
from dbo.condition_occurrence a
join xref.concept b
on a.condition_concept_id = b.concept_id
where b.domain_id = 'Procedure'

delete a
from dbo.condition_occurrence a
join xref.concept b
on a.condition_concept_id = b.concept_id
where b.domain_id = 'Procedure';
GO

SET NOCOUNT OFF;
