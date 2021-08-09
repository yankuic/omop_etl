/*
Find merged patnt_keys
*/
SET NOCOUNT ON;

WHILE (
	SELECT count(*)
	FROM [xref].[PERSON_MAPPING] a
	JOIN DWS_PROD.dbo.PATIENT_ID_MERGE_EVENT b
	ON a.PATIENT_KEY = b.PREV_PATNT_KEY
	LEFT OUTER JOIN [xref].[PERSON_MAPPING] c
	ON b.PATNT_KEY = c.PATIENT_KEY
) > 0
BEGIN
	UPDATE a
	SET a.PATIENT_KEY = b.PATNT_KEY,
		a.MERGE_IND = case 
						when c.PERSON_ID is not null then 'Y' 
						else a.MERGE_IND 
					  end,
		a.MERGE_DT = B.LOAD_DT
	FROM xref.PERSON_MAPPING a
	JOIN DWS_PROD.dbo.PATIENT_ID_MERGE_EVENT b
	ON a.PATIENT_KEY = b.PREV_PATNT_KEY
	LEFT OUTER JOIN xref.PERSON_MAPPING c
	ON b.PATNT_KEY = c.PATIENT_KEY
END

/*
Flag patids from merged patnt_keys
*/
UPDATE B
SET MERGE_IND = 'Y'
FROM xref.PERSON_MAPPING A
JOIN xref.PERSON_MAPPING B
ON A.PATIENT_KEY = B.PATIENT_KEY
WHERE A.MERGE_IND = 'N'
AND B.MERGE_IND = 'N'
AND A.PERSON_ID > B.PERSON_ID

/*
Deactivate merged patnt_keys
*/
update xref.PERSON_MAPPING
set ACTIVE_IND = 'N'

update b
set ACTIVE_IND = 'Y'
from stage.PERSON a
join xref.PERSON_MAPPING b
on a.PATIENT_KEY = b.PATIENT_KEY
where b.MERGE_IND = 'N'

SET NOCOUNT OFF;

/*
Insert new patients into patient_mapping
*/
insert into xref.person_mapping (
	patient_key
	,date_shift 
	,load_dt
	,merge_ind
	,merge_dt
	,active_ind
)
select patient_key
	,date_shift = 0
	,load_dt = getdate()
	,merge_ind = 'N'
	,merge_dt = NULL
	,active_ind = 'Y'
	from (
		select distinct
			a.patient_key
			from [stage].person a
			left join [xref].person_mapping b
			on a.patient_key = b.patient_key
		where b.patient_key is null
) x

--Set date_shift <> 0 for all patients
while (
	select count(*)
	from xref.person_mapping
	where date_shift = 0
	and active_ind = 'Y'
) > 0
begin
	update xref.person_mapping 
	set date_shift = ceiling(30-60*rand(checksum(newid())))
	where date_shift = 0
	and active_ind = 'Y'
end

/*
Rebuild index and columnstore
*/
ALTER INDEX [xpk_person_mapping] ON [xref].[person_mapping] 
REBUILD PARTITION = ALL WITH (SORT_IN_TEMPDB = ON)

DROP INDEX IF EXISTS [csix_person_mapping] ON [xref].[person_mapping]
CREATE NONCLUSTERED COLUMNSTORE INDEX [csix_person_mapping] ON [xref].[person_mapping]
(
	 [PERSON_ID]
	,[PATIENT_KEY]
	,[LOAD_DT]
	,[MERGE_IND]
	,[MERGE_DT]
	,[ACTIVE_IND]
) ON [fg_user1]
