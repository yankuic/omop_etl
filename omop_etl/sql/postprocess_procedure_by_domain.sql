/* Move records by domain */

SET NOCOUNT ON;

exec('
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
	where b.domain_id = ''Measurement''

	delete a
	from dbo.procedure_occurrence a
	join xref.concept b
	on a.procedure_concept_id = b.concept_id
	where b.domain_id = ''Measurement'''
)

exec('
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
		,value_as_concept_id = 4077689
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
	where b.domain_id = ''Observation''

	delete a
	from dbo.procedure_occurrence a
	join xref.concept b
	on a.procedure_concept_id = b.concept_id
	where b.domain_id = ''Observation'''
)

exec('
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
		,drug_exposure_start_datetime = a.procedure_datetime  --This is not necessarily true, but this is a required field, so use the best approximation that we can.
		,drug_exposure_end_date = a.procedure_date
		,drug_exposure_end_datetime = a.procedure_datetime
		,verbatim_end_date = NULL
		,drug_type_concept_id = a.procedure_type_concept_id
		,stop_reason = NULL
		,refills = NULL
		,quantity = NULL  --We do not know the quantity. By default, we use 1 for all procedures, but the fact that there is one procedure does not mean that there was one tablet given.
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
	where b.domain_id = ''Drug''

	delete a
	from dbo.procedure_occurrence a 
	join xref.concept b 
	on a.procedure_concept_id = b.concept_id
	where b.domain_id = ''Drug'''
)

exec('
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
		,quantity = NULL  --We do not know the quantity. By default, we use 1 for all procedures, but the fact that there is one procedure does not mean that there is one device.
		,provider_id = a.provider_id
		,visit_occurrence_id = a.visit_occurrence_id
		,visit_detail_id = NULL
		,device_source_value = a.procedure_source_value
		,device_source_concept_id = a.procedure_source_concept_id
	from dbo.procedure_occurrence a 
	join xref.concept b 
	on a.procedure_concept_id = b.concept_id 
	where b.domain_id = ''Device''

	delete a
	from dbo.procedure_occurrence a 
	join xref.concept b 
	on a.procedure_concept_id = b.concept_id 
	where b.domain_id = ''Device'''
)

SET NOCOUNT OFF;
