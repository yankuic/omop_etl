IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'cohort')
BEGIN
	EXEC( 'CREATE SCHEMA cohort' );
END

CREATE TABLE [cohort].[PersonList](

	[PATIENT_KEY] [int] NOT NULL

) ON [fg_user1]

