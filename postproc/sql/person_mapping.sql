USE [DWS_OMOP]
GO
/****** Object:  StoredProcedure [dbo].[PROCESS_STAGE_PERSON_MAPPING]    Script Date: 11/5/2020 11:33:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[person_mapping] as

	/*
	Find merged patnt_keys
	*/
	UPDATE a
	SET a.PATNT_KEY = b.PATNT_KEY,
		a.MERGE_IND = case 
						when c.PERSON_ID is not null then 'Y' 
						else a.MERGE_IND 
					   end,
		a.MERGE_DT = B.LOAD_DT
	FROM [dbo].[PERSON_MAPPING] a
	JOIN DWS_PROD.dbo.PATIENT_ID_MERGE_EVENT b
	ON a.PATNT_KEY = b.PREV_PATNT_KEY
	LEFT OUTER JOIN [dbo].[PERSON_MAPPING] c
	ON b.PATNT_KEY = c.PATNT_KEY;

	/*
	Run twice to catch double merges
	*/
	UPDATE a
	SET a.PATNT_KEY = b.PATNT_KEY,
		a.MERGE_IND = case 
						when c.PERSON_ID is not null then 'Y' 
						else a.MERGE_IND 
					  end,
		a.MERGE_DT = B.LOAD_DT
	FROM [dbo].[PERSON_MAPPING] a
	JOIN DWS_PROD.dbo.PATIENT_ID_MERGE_EVENT b
	ON a.PATNT_KEY = b.PREV_PATNT_KEY
	LEFT OUTER JOIN [dbo].[PERSON_MAPPING] c
	ON b.PATNT_KEY = c.PATNT_KEY

	/*
	Fix any where two separate patnt_keys merged into one new
	*/
	UPDATE B
	SET MERGE_IND = 'Y'
	FROM [dbo].[PERSON_MAPPING] A
	JOIN [dbo].[PERSON_MAPPING] B
	ON A.PATNT_KEY = B.PATNT_KEY
	WHERE A.MERGE_IND = 'N'
	AND B.MERGE_IND = 'N'
	AND A.PERSON_ID > B.PERSON_ID

	/*
	Deactivate merged patnt_keys
	*/
	update  [dbo].[PERSON_MAPPING]
	set ACTIVE_IND = 'N'

	update b
	set ACTIVE_IND = 'Y'
	from  [dbo].[STAGE_PERSON] a
	join  [dbo].[PERSON_MAPPING] b
	on a.PATNT_KEY = b.PATNT_KEY
	where b.MERGE_IND = 'N'

	/*
	Insert new patients into patient_mapping
	*/
	insert into person_mapping (
		patient_key
		,load_dt
		,merge_ind
		,merge_dt
		,active_ind
	)
	select patient_key
		  ,load_dt = getdate()
		  ,merge_ind = 'N'
		  ,merge_dt = NULL
		  ,active_ind = 'Y'
      from (
		select distinct
			a.patient_key
		  from [stage].person a
		  left join [dbo].person_mapping b
			on a.patient_key = b.patient_key
		where b.patient_key is null
	) x
	
	/*
	Rebuild index and columnstore
	*/
	ALTER INDEX [xpk_person_mapping] ON [dbo].[person_mapping] REBUILD PARTITION = ALL WITH (SORT_IN_TEMPDB = ON)
	
	CREATE NONCLUSTERED COLUMNSTORE INDEX [csix_person_mapping] ON [dbo].[person_mapping]
	(
		 [PERSON_ID]
		,[PATIENT_KEY]
		,[LOAD_DT]
		,[MERGE_IND]
		,[MERGE_DT]
		,[ACTIVE_IND]
	)WITH (DROP_EXISTING = ON) ON [PRIMARY]


