
insert into dbo.death
select b.[person_id]
      ,[death_date] = ISNULL(a.PATNT_DTH_DATE, a.PATNT_SSN_DTH_DATE)
      ,[death_datetime] = ISNULL(a.PATNT_DTH_DATE, a.PATNT_SSN_DTH_DATE)
      ,[death_type_concept_id] = CASE WHEN a.PATNT_DTH_DATE IS NULL THEN 32885 ELSE 32817 END
      ,[cause_concept_id] = 0
      ,[cause_source_value] = NULL
      ,[cause_source_concept_id] = 0
  from stage.death a
  join xref.person_mapping b
  on a.PATIENT_KEY = b.patient_key
where b.active_ind = 'Y'
