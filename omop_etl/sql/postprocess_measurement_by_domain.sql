/* Move records by domain */

SET NOCOUNT ON;

exec('
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
	from dbo.measurement a
	join xref.concept b
	on a.measurement_concept_id = b.concept_id
	where b.domain_id = ''Observation''

	select measurement_id
	into #ids
	from dbo.measurement a
	join xref.concept b
	on a.measurement_concept_id = b.concept_id
	where b.domain_id = ''Observation''
	order by measurement_id asc

	while (
		select count(*)
		from #ids
	) > 0
	begin

		drop table if exists #delete_ids
		select top 1000000 measurement_id 
		into #delete_ids
		from #ids

		begin transaction
		delete x from (
			select *
			from dbo.measurement
			where measurement_id in (select * from #delete_ids)
		)x

		delete from #ids 
		where measurement_id in (select * from #delete_ids)
		
		commit transaction;
		checkpoint;

	end

	drop table if exists #ids
'
)

SET NOCOUNT OFF;
