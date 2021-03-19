/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) a.person_id
      ,date_shift
	  ,DATEDIFF(day, c.patnt_birth_datetime, birth_datetime) [datediff]
      ,[year_of_birth]
      ,[month_of_birth]
      ,[day_of_birth]
      ,[birth_datetime]
	  ,c.patnt_birth_datetime
  FROM [DWS_OMOP].[dbo].[person] a
  join xref.person_mapping b
  on a.person_id = b.person_id
  join stage.[PERSON] c
  on b.patient_key = c.patient_key

  /****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) a.[visit_occurrence_id]
      ,a.[person_id]
	  ,date_shift
	  ,DATEDIFF(day, d.encounter_effective_date, visit_start_date) [start_datediff]
	  ,DATEDIFF(day, d.[dischg_date], visit_end_date) [end_datediff]
      ,[visit_start_date]
	  ,d.encounter_effective_date
      ,[visit_start_datetime]
      ,[visit_end_date]
      ,[visit_end_datetime]
	  ,d.[dischg_date]
  FROM [DWS_OMOP].[dbo].[visit_occurrence] a
  join xref.person_mapping b 
  on a.person_id = b.person_id 
  join xref.visit_occurrence_mapping c
  on a.visit_occurrence_id = c.visit_occurrence_id
  join stage.VISIT d
  on c.patnt_encntr_key = d.patnt_encntr_key

/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) a.person_id
	  ,date_shift 
	  ,datediff(day, c.patnt_dth_date, a.death_date)
	  ,datediff(day, a.death_date, c.patnt_ssn_dth_date)
	  ,a.death_date
	  ,c.patnt_dth_date
	  ,c.patnt_ssn_dth_date
  FROM [DWS_OMOP].[dbo].[death] a
  join xref.person_mapping b
  on a.person_id = b.person_id
  join stage.DEATH c
  on b.patient_key = c.patient_key

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
  FROM [DWS_OMOP].[dbo].[drug_exposure] a
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
  FROM [DWS_OMOP].[dbo].[measurement] a
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
  FROM [DWS_OMOP].[dbo].[observation] a
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

