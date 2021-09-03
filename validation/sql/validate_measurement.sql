USE [DWS_CC_OMOP]
GO
/****** Object:  StoredProcedure [dbo].[validate_measurement]    Script Date: 9/2/2021 11:08:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[validate_measurement] 
AS
BEGIN

	-- create median table to later merge with numeric measurement table

	IF object_id(N'tempdb..#measurementMedian') IS NOT NULL
		DROP TABLE #measurementMedian

	select DISTINCT 
		f.measurement_concept_id, 
		PERCENTILE_CONT(0.5) 
		WITHIN GROUP (ORDER BY f.value_as_number)
		OVER (PARTITION BY f.measurement_concept_id) AS measure_median
	into #measurementMedian
	from
		dbo.measurement f

	-- create the list of numeric measurement to later merge with measurement table

	IF object_id(N'tempdb..#measurement_numList') IS NOT NULL
		DROP TABLE #measurement_numList

	--SELECT 
	--	distinct measurement_source_value
	--INTO
	--	#measurement_numList
	--FROM 
	--	dbo.measurement f
	--left join 
	--xref.concept x
	--	on f.measurement_concept_id = x.concept_id
	--where 
	--	concept_class_id like '%Clinical Observation%' and isnumeric(value_as_number) = 1

	SELECT 
		distinct measurement_source_value
	INTO
		#measurement_numList
	FROM 
		dbo.measurement
	  where (substring(measurement_source_value,2,1)  LIKE '%[a-Z]%' 
	  or substring(measurement_source_value,3,1)  LIKE '%[a-Z]%' 
	  or substring(measurement_source_value,4,1)  LIKE '%[a-Z]%')
	  and isnumeric(value_as_number) = 1

	-- create the full numeric measurement table
	IF object_id(N'tempdb..#measurementNum') IS NOT NULL
		DROP TABLE #measurementNum

	SELECT 
		f.measurement_concept_id, 
		f.measurement_source_value, 
		f.unit_source_value, 	
		x.domain_id, 
		x.vocabulary_id, 
		x.concept_class_id, 
		x.standard_concept,
		min(f.value_as_number) as measure_min, 
		max(f.value_as_number) as measure_max, 
		AVG(f.value_as_number) as measure_mean,
		m.measure_median,
		stdev(f.value_as_number) as measure_stdev,
		min(f.measurement_date) as date_min,
		max(f.measurement_date) as date_max,
		count(DISTINCT f.visit_occurrence_id) as visit_count,
		count(DISTINCT f.person_id) as patient_count,
		-- null_rowcount based on value_as_number
		sum(case when f.value_as_number is null then 1 else 0 end ) as null_rowcount_van,
		-- null_rowcount based on value_source_value
		sum(case when f.value_source_value is null then 1 else 0 end ) as null_rowcount_vsv,
		count(*) as rowcouont
	into #measurementNum
	FROM 
		dbo.measurement f
	left join 
		xref.concept x
			on f.measurement_concept_id = x.concept_id
	left join #measurementMedian m
			on  f.measurement_concept_id = m.measurement_concept_id
	inner join #measurement_numList l
			on f.measurement_source_value = l.measurement_source_value
	--where x.concept_class_id = 'Clinical Observation' 
	group by  
		f.measurement_concept_id, f.measurement_source_value, f.unit_source_value, x.domain_id, x.vocabulary_id, x.concept_class_id, x.standard_concept, m.measure_median
	order by 
		f.measurement_source_value


	-- create the measurement table with string as source value
	IF object_id(N'tempdb..#measurementString') IS NOT NULL
		DROP TABLE #measurementString

	SELECT  distinct  
		f.measurement_concept_id, 
		f.measurement_source_value, 
		f.unit_source_value,
		x.domain_id, 
		x.vocabulary_id, 
		x.concept_class_id, 
		x.standard_concept,
		f.value_source_value,
		count(DISTINCT f.visit_occurrence_id) as visit_count,
		count(DISTINCT f.person_id) as patient_count,
		sum(case when f.value_source_value is null then 1 else 0 end ) as null_rowcount_vsv,
		count(*) as rowcouont
	into #measurementString
	FROM 
		dbo.measurement f
	left join 
		xref.concept x
			on f.measurement_concept_id = x.concept_id
	where 
	x.concept_class_id = 'Clinical Observation' and 
	f.value_source_value like '%[a-Z]%'
		and
		f.measurement_source_value not in (
			select measurement_source_value from #measurement_numList
		)
	group by f.measurement_concept_id, f.measurement_source_value, f.unit_source_value, x.domain_id, x.vocabulary_id, x.concept_class_id, x.standard_concept, f.value_source_value
	order by measurement_source_value, value_source_value

	-- merge the measurement tables with string and numberic values
	IF object_id('validation.measurement') IS NOT NULL
		DROP TABLE validation.measurement

	select * 
	into validation.measurement
	from (
		select 	'numeric	' as data_type,
				measurement_concept_id, 
				measurement_source_value, 
				unit_source_value, 	
				domain_id, 
				vocabulary_id, 
				concept_class_id, 
				standard_concept,
				measure_min, 
				measure_max, 
				measure_mean,
				measure_median,
				measure_stdev,
				date_min,
				date_max,
				null as value_source_value,
				visit_count,
				patient_count,
				rowcouont,
				null_rowcount_van,
				null_rowcount_vsv
		from #measurementNum 
		--where  concept_class_id = 'Clinical Observation'
		union all 
		select  'categorical' as data_type,
				measurement_concept_id, 
				measurement_source_value, 
				unit_source_value,
				domain_id, 
				vocabulary_id, 
				concept_class_id, 
				standard_concept,
				null as measure_min, 
				null as measure_max, 
				null as measure_mean,
				null as measure_median,
				null as measure_stdev,
				null as date_min,
				null as date_max,
				value_source_value,
				visit_count,
				patient_count,
				rowcouont,
				null as null_rowcount_van,
				null_rowcount_vsv
		from #measurementString
		--where  concept_class_id = 'Clinical Observation'
	) a


END