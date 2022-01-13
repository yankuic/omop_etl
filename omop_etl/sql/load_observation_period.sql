insert into [dbo].[observation_period] with(tablock)
SELECT a.[person_id]
      ,[observation_period_start_date] = a.visit_start_date
      ,[observation_period_end_date] = a.visit_end_date
      ,[period_type_concept_id] = 32817
  FROM (
	SELECT person_id, 
			MIN(visit_start_date) visit_start_date, 
			MAX(visit_end_date) visit_end_date
	FROM dbo.visit_occurrence
	GROUP BY person_id
) a 
join xref.person_mapping b 
on a.person_id = b.person_id
and b.active_ind = 'Y'
