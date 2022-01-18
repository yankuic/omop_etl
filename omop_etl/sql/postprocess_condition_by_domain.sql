/* Move records by domain 

Condition occurrence -> Measurement
Condition occurrence -> Observation
Condition occurrence -> Procedure occurrence
*/

SET NOCOUNT ON;

exec('
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
	where b.domain_id = ''Measurement''

	delete a
	from dbo.condition_occurrence a
	join xref.concept b
	on a.condition_concept_id = b.concept_id
	where b.domain_id = ''Measurement'''
)

exec('
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
	where b.domain_id = ''Observation''

	drop table if exists #ids
	select condition_occurrence_id
	into #ids
	from dbo.condition_occurrence a
	join xref.concept b
	on a.condition_concept_id = b.concept_id
	where b.domain_id = ''Observation''
	order by condition_occurrence_id asc

	while (
		select count(*)
		from #ids
	) > 0
	begin

		drop table if exists #delete_ids
		select top 1000000 condition_occurrence_id 
		into #delete_ids
		from #ids

		begin transaction
		delete x from (
			select *
			from dbo.condition_occurrence
			where condition_occurrence_id in (select * from #delete_ids)
		)x

		delete from #ids 
		where condition_occurrence_id in (select * from #delete_ids)
		
		commit transaction;
		checkpoint;

	end

	drop table if exists #ids'
)

exec('
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
	where b.domain_id = ''Procedure''

	delete a
	from dbo.condition_occurrence a
	join xref.concept b
	on a.condition_concept_id = b.concept_id
	where b.domain_id = ''Procedure'''
)

SET NOCOUNT OFF;
