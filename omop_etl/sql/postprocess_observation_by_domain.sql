/* Move records by domain */

SET NOCOUNT ON;

exec('
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
	where b.domain_id = ''Measurement''

	delete a
	from dbo.observation a
	join xref.concept b
	on a.observation_concept_id = b.concept_id
	where b.domain_id = ''Measurement'''
)

exec('
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
	where b.domain_id = ''Condition''

	delete a
	from dbo.observation a
	join xref.concept b
	on a.observation_concept_id = b.concept_id
	where b.domain_id = ''Condition'''
)

SET NOCOUNT OFF;
