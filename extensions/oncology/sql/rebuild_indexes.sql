USE [DWS_CC_OMOP]
GO

/****** CONDITION_OCCURRENCE ******/
DROP INDEX [ix_personid_conditionconceptid] ON [dbo].[CONDITION_OCCURRENCE]
DROP INDEX [ix_conditionconceptid_personid] ON [dbo].[CONDITION_OCCURRENCE]
ALTER TABLE [dbo].[CONDITION_OCCURRENCE] DROP CONSTRAINT [pk_condition_occurrence] WITH ( ONLINE = OFF )

CREATE NONCLUSTERED INDEX [ix_conditionconceptid_personid] ON [dbo].[CONDITION_OCCURRENCE]
(
	[condition_concept_id] ASC,
	[person_id] ASC
)WITH (PAD_INDEX = OFF
		,STATISTICS_NORECOMPUTE = OFF
		,SORT_IN_TEMPDB = OFF
		,DROP_EXISTING = OFF
		,ONLINE = OFF
		,ALLOW_ROW_LOCKS = ON
		,ALLOW_PAGE_LOCKS = ON
		,OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [fg_user1]

CREATE NONCLUSTERED INDEX [ix_personid_conditionconceptid] ON [dbo].[CONDITION_OCCURRENCE]
(
	[person_id] ASC,
	[condition_concept_id] ASC
)WITH (PAD_INDEX = OFF
		,STATISTICS_NORECOMPUTE = OFF
		,SORT_IN_TEMPDB = OFF
		,DROP_EXISTING = OFF
		,ONLINE = OFF
		,ALLOW_ROW_LOCKS = ON
		,ALLOW_PAGE_LOCKS = ON
		,OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [fg_user1]

ALTER TABLE [dbo].[CONDITION_OCCURRENCE] ADD  CONSTRAINT [pk_condition_occurrence] PRIMARY KEY CLUSTERED 
(
	[condition_occurrence_id] ASC,
	[person_id] ASC,
	[condition_concept_id] ASC
)WITH (PAD_INDEX = OFF
		,STATISTICS_NORECOMPUTE = OFF
		,SORT_IN_TEMPDB = OFF
		,IGNORE_DUP_KEY = OFF
		,ONLINE = OFF
		,ALLOW_ROW_LOCKS = ON
		,ALLOW_PAGE_LOCKS = ON
		,OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [fg_user1]


/****** MEASUREMENT ******/
DROP INDEX [ix_measurementconceptid_personid] ON [dbo].[MEASUREMENT]
DROP INDEX [ix_personid_measurementconceptid] ON [dbo].[MEASUREMENT]
ALTER TABLE [dbo].[MEASUREMENT] DROP CONSTRAINT [pk_measurement] WITH ( ONLINE = OFF )

CREATE NONCLUSTERED INDEX [ix_measurementconceptid_personid] ON [dbo].[MEASUREMENT]
(
	[measurement_concept_id] ASC,
	[person_id] ASC
)WITH (PAD_INDEX = OFF
		,STATISTICS_NORECOMPUTE = OFF
		,SORT_IN_TEMPDB = OFF
		,DROP_EXISTING = OFF
		,ONLINE = OFF
		,ALLOW_ROW_LOCKS = ON
		,ALLOW_PAGE_LOCKS = ON
		,OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [fg_user1]

CREATE NONCLUSTERED INDEX [ix_personid_measurementconceptid] ON [dbo].[MEASUREMENT]
(
	[person_id] ASC,
	[measurement_concept_id] ASC
)WITH (PAD_INDEX = OFF
		,STATISTICS_NORECOMPUTE = OFF
		,SORT_IN_TEMPDB = OFF
		,DROP_EXISTING = OFF
		,ONLINE = OFF
		,ALLOW_ROW_LOCKS = ON
		,ALLOW_PAGE_LOCKS = ON
		,OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [fg_user1]

ALTER TABLE [dbo].[MEASUREMENT] ADD  CONSTRAINT [pk_measurement] PRIMARY KEY CLUSTERED 
(
	[measurement_id] ASC,
	[person_id] ASC,
	[measurement_concept_id] ASC
)WITH (PAD_INDEX = OFF
		,STATISTICS_NORECOMPUTE = OFF
		,SORT_IN_TEMPDB = OFF
		,IGNORE_DUP_KEY = OFF
		,ONLINE = OFF
		,ALLOW_ROW_LOCKS = ON
		,ALLOW_PAGE_LOCKS = ON
		,OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [fg_user1]

/****** OBSERVATION ******/
DROP INDEX [ix_observationconceptid_personid] ON [dbo].[OBSERVATION]
DROP INDEX [ix_personid_observationconceptid] ON [dbo].[OBSERVATION]
ALTER TABLE [dbo].[OBSERVATION] DROP CONSTRAINT [pk_observation] WITH ( ONLINE = OFF )

CREATE NONCLUSTERED INDEX [ix_observationconceptid_personid] ON [dbo].[OBSERVATION]
(
	[observation_concept_id] ASC,
	[person_id] ASC
)WITH (PAD_INDEX = OFF
		,STATISTICS_NORECOMPUTE = OFF
		,SORT_IN_TEMPDB = OFF
		,DROP_EXISTING = OFF
		,ONLINE = OFF
		,ALLOW_ROW_LOCKS = ON
		,ALLOW_PAGE_LOCKS = ON
		,OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [fg_user1]

CREATE NONCLUSTERED INDEX [ix_personid_observationconceptid] ON [dbo].[OBSERVATION]
(
	[person_id] ASC,
	[observation_concept_id] ASC
)WITH (PAD_INDEX = OFF
		,STATISTICS_NORECOMPUTE = OFF
		,SORT_IN_TEMPDB = OFF
		,DROP_EXISTING = OFF
		,ONLINE = OFF
		,ALLOW_ROW_LOCKS = ON
		,ALLOW_PAGE_LOCKS = ON
		,OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [fg_user1]

ALTER TABLE [dbo].[OBSERVATION] ADD  CONSTRAINT [pk_observation] PRIMARY KEY CLUSTERED 
(
	[observation_id] ASC,
	[person_id] ASC,
	[observation_concept_id] ASC
)WITH (PAD_INDEX = OFF
		,STATISTICS_NORECOMPUTE = OFF
		,SORT_IN_TEMPDB = OFF
		,IGNORE_DUP_KEY = OFF
		,ONLINE = OFF
		,ALLOW_ROW_LOCKS = ON
		,ALLOW_PAGE_LOCKS = ON
		,OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [fg_user1]

