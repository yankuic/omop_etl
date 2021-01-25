/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [TABLE_NAME]
      ,[SQL_QUERY]
      ,[DATATIME_QUERY]
      ,[ROW_COUNT]
  FROM [DWS_OMOP].[stage].[query_log]

  truncate table stage.query_LOG

  DROP TABLE  stage.query_LOG

  CREATE TABLE [stage].query_log(
	SCHEMA_NAME [varchar] (100) null,
	TABLE_NAME [varchar] (100) NULL,
	SQL_QUERY [varchar] (max) NULL,
	ROW_COUNT [int] NULL,
	REFRESH_DATETIME [datetime2] NULL,
	MODIFY_DATETIME [datetime2] NULL,
	ELAPSED_TIME [varchar] (100) NULL,
	CREATE_DATETIME [datetime2] 
	)ON [fg_user1]



