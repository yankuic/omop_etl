/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) a.person_id
      ,date_shift
	  ,DATEDIFF(day, c.birth_datetime, a.birth_datetime) [datediff]
      ,a.[year_of_birth]
      ,a.[month_of_birth]
      ,a.[day_of_birth]
      ,c.[birth_datetime]
  FROM [dbo].[person] a
  join xref.person_mapping b
  on a.person_id = b.person_id
  join hipaa.[PERSON] c
  on b.person_id = c.person_id

  /****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) a.[visit_occurrence_id]
      ,a.[person_id]
	  ,d.person_id
	  ,date_shift
	  ,DATEDIFF(day, a.visit_start_date, d.visit_start_date) diff
      ,a.[visit_start_date]
	  ,d.[visit_start_date]
  FROM [dbo].[visit_occurrence] a
  join xref.person_mapping b 
  on a.person_id = b.person_id 
  join hipaa.[visit_occurrence] d
  on a.visit_occurrence_id = d.visit_occurrence_id

/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) a.person_id
	  ,date_shift 
	  ,datediff(day, c.death_date, a.death_date)
	  ,a.death_date
	  ,c.death_date
  FROM [dbo].[death] a
  join xref.person_mapping b
  on a.person_id = b.person_id
  join hipaa.DEATH c
  on a.person_id = c.person_id

SELECT TOP (1000) a.condition_occurrence_id
    ,a.person_id
	,c.person_id
	,a.visit_occurrence_id
	,c.visit_occurrence_id
	,b.date_shift 
	,datediff(day, c.condition_start_date, a.condition_start_date)
	,a.condition_start_date
	,c.condition_start_date
FROM dbo.condition_occurrence a
join xref.person_mapping b
on a.person_id = b.person_id
join hipaa.condition_occurrence c
on a.condition_occurrence_id = c.condition_occurrence_id

/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [condition_occurrence_id]
      ,a.person_id
	  ,b.person_id
	  ,a.visit_occurrence_id
	  ,b.visit_occurrence_id
	  ,b.date_shift 
	  ,datediff(day, b.condition_start_date, a.condition_start_date) start_datediff
	  ,datediff(day, b.condition_end_date, a.condition_end_date) end_datediff
      ,a.condition_start_date
	  ,b.condition_start_date
      ,a.condition_end_date
	  ,b.condition_end_date
  FROM dbo.condition_occurrence a
  join (
		select date_shift, 
			  DATEADD(day, date_shift, b.condition_start_date) new_start_date, 
			  DATEADD(day, date_shift, b.condition_end_date) new_end_date,
			  b.* 
		from preload.condition_occurrence b 
		join xref.person_mapping c
		on b.person_id = c.person_id
) b
on a.person_id = b.person_id 
and a.condition_concept_id = b.condition_concept_id
and a.visit_occurrence_id = b.visit_occurrence_id
and a.condition_source_value = b.condition_source_value
and a.condition_start_date = b.new_start_date
and a.condition_end_date = b.new_end_date

/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [drug_exposure_id]
      ,a.person_id
	  ,date_shift
	  ,datediff(day, b.drug_exposure_start_date, a.drug_exposure_start_date) start_datediff
	  ,datediff(day, b.drug_exposure_end_date, a.drug_exposure_end_date) end_datediff
      ,a.drug_exposure_start_date
      ,a.drug_exposure_start_datetime
      ,a.drug_exposure_end_date
      ,a.drug_exposure_end_datetime
      ,a.verbatim_end_date
      ,a.visit_occurrence_id
  FROM [dbo].[drug_exposure] a
  join (
		select date_shift, 
			  DATEADD(day, date_shift, b.drug_exposure_start_datetime) new_start_date, 
			  DATEADD(day, date_shift, b.drug_exposure_end_datetime) new_end_date,
			  b.* 
		from preload.drug_exposure b 
		join xref.person_mapping c
		on b.person_id = c.person_id
) b
on a.person_id = b.person_id 
and a.drug_concept_id = b.drug_concept_id
and a.visit_occurrence_id = b.visit_occurrence_id
and a.quantity = b.quantity
and a.provider_id = b.provider_id
and a.drug_source_value = b.drug_source_value
and a.drug_exposure_start_datetime = b.new_start_date
and a.drug_exposure_end_datetime = b.new_end_date

/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [measurement_id]
      ,a.person_id
	  ,b.person_id
	  ,date_shift
	  ,datediff(day, b.measurement_date, a.measurement_date) start_datediff
      ,a.measurement_date
	  ,b.measurement_date
      ,a.measurement_datetime
      ,a.visit_occurrence_id
	  ,b.visit_occurrence_id
  FROM [dbo].[measurement] a
  join (
		select date_shift, 
			  DATEADD(day, date_shift, b.measurement_datetime) new_date, 
			  b.* 
		from preload.measurement b 
		join xref.person_mapping c
		on b.person_id = c.person_id
) b
on a.person_id = b.person_id 
and a.measurement_concept_id = b.measurement_concept_id
and a.visit_occurrence_id = b.visit_occurrence_id
and a.provider_id = b.provider_id
and a.value_as_number = b.value_as_number
and a.measurement_source_value = b.measurement_source_value
and a.measurement_datetime = b.new_date


/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) a.[observation_period_id]
      ,a.person_id
	  ,b.date_shift
	  ,datediff(day, c.observation_period_start_date, a.observation_period_start_date) start_datediff
	  ,a.observation_period_start_date
	  ,c.observation_period_start_date
FROM [dbo].[observation_period] a
join xref.person_mapping b
on b.person_id = a.person_id
join hipaa.observation_period c
on a.observation_period_id = c.observation_period_id


SELECT TOP (1000) [observation_id]
      ,a.person_id
	  ,b.person_id
	  ,date_shift
	  ,datediff(day, b.observation_date, a.observation_date) start_datediff
      ,a.observation_date
	  ,b.observation_date
      ,a.observation_datetime
      ,a.visit_occurrence_id
	  ,b.visit_occurrence_id
  FROM [dbo].[observation] a
  join (
		select date_shift, 
			  DATEADD(day, date_shift, b.observation_datetime) new_date, 
			  b.* 
		from preload.observation b 
		join xref.person_mapping c
		on b.person_id = c.person_id
) b
on a.person_id = b.person_id 
and a.observation_concept_id = b.observation_concept_id
and a.visit_occurrence_id = b.visit_occurrence_id
and a.provider_id = b.provider_id
and a.value_as_number = b.value_as_number
and a.observation_source_value = b.observation_source_value
and a.observation_datetime = b.new_date

