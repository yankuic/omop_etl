
truncate table dbo.death
insert into @Schema.death
select b.[person_id]
      ,[death_date] = dateadd(day, @DateShift, ISNULL(a.PATNT_DTH_DATE, a.PATNT_SSN_DTH_DATE))
      ,[death_datetime] = dateadd(day, @DateShift, ISNULL(a.PATNT_DTH_DATE, a.PATNT_SSN_DTH_DATE))
      ,[death_type_concept_id] = CASE WHEN a.PATNT_DTH_DATE IS NULL THEN 32885 ELSE 32817 END
      ,[cause_concept_id] = 0
      ,[cause_source_value] = NULL
      ,[cause_source_concept_id] = 0
  from stage.death a
  join xref.person_mapping b
  on a.PATIENT_KEY = b.patient_key
where b.active_ind = 'Y'
