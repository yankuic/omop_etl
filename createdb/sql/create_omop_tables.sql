USE [DWS_OMOP]
GO

/****** 
	RULE OF NAMING COLUMNS: USE DWS COLUMN NAMES IF CLEAR ENOUGH; OTHERWISE, USE BO OBJECT NAME 
	i.e. ALL_SEXES.STNDRD_LABEL from DWS is not clear enough. Thus, use SEX from BO instead.
******/



DROP TABLE IF EXISTS [stage].[PERSON]
CREATE TABLE [stage].[PERSON](
	PATIENT_KEY [int] NOT NULL,  --ALL_PATIENTS.PATNT_KEY
	SEX [varchar](50)  NULL, -- ALL_SEXES.STNDRD_LABEL
	RACE [varchar](50)  NULL, -- ALL_RACES.STNDRD_LABEL
	ETHNICITY [varchar](50)  NULL, --ALL_ETHNIC_GROUPS.STNDRD_LABEL
	ADDR_KEY [int]  NULL, --ALL_ADDRESSES_RECENT.ADDR_KEY
	PATNT_BIRTH_DATETIME [datetime2] NULL, --ALL_PATIENTS.patnt_birth_datetime
	PATIENT_REPORTED_PCP_PROV_KEY [int]  NULL, -- ALL_PROVIDERS_PAT_RPTD_PCP.PROVIDR_KEY
	PATIENT_REPORTED_PRIMARY_DEPT_ID [int]  NULL --ALL_HOSPITAL_ORGANIZATION_PT_PRIM_LOC.DEPT_ID
) ON [fg_user1]


DROP TABLE IF EXISTS [stage].[DEATH]
CREATE TABLE [stage].[DEATH](
	PATIENT_KEY [int] NOT NULL, --ALL_PATIENTS.PATNT_KEY
	PATNT_DTH_DATE [date] NULL , -- ALL_PATIENTS.PATNT_DTH_DATE
	PATNT_SSN_DTH_DATE [date] NULL  --ALL_PATIENTS.PATNT_SSN_DTH_DATE 
) ON [fg_user1]

DROP TABLE IF EXISTS [stage].CONDITION
CREATE TABLE [stage].[CONDITION](
	PATIENT_KEY [int] , --ALL_PATIENTS.PATNT_KEY,  
	START_DATE [date] NULL ,--DIAGNOSIS_EVENT_DTL.START_DATE,  
	END_DATE [date] NULL,  --DIAGNOSIS_EVENT_DTL.END_DATE,  
	DIAG_CD_DECML [varchar](8) NULL,--ALL_ICD_DIAGNOSIS_CODES.DIAG_CD_DECML,  
	DIAGNOSIS_TYPE [varchar](254) NULL, --DIAGNOSIS_EVENT_DTL.DIAGNOSIS_TYPE,  
	ICD_TYPE [varchar](10) NULL, --DIAGNOSIS_EVENT_DTL.ICD_TYPE,
	CONDITION_POA [varchar](254) NULL,  --ALL_POA_INDICATORS.STNDRD_LABEL,  
	PROVIDR_KEY [int]  NULL, --ALL_PROVIDERS.PROVIDR_KEY,  
	PATNT_ENCNTR_KEY [decimal](18, 0)  NULL--PATNT_ENCNTR_KEY_XREF.PATNT_ENCNTR_KEY
) ON [fg_user1]


DROP TABLE IF EXISTS [stage].PROCEDURE_CPT
CREATE TABLE [stage].PROCEDURE_CPT(
	PATIENT_KEY [int], --PX_ALL_PATIENTS.PATNT_KEY,  
	START_DATE [date]  ,--PROCEDURE_EVENT_DTL.START_DATE, 
	PROCEDURE_TYPE [varchar] (50),--PROCEDURE_EVENT_DTL.PROCEDURE_TYPE,  
	CPT_CD [varchar] (200), -- ALL_CPT_PROCEDURE_CODES.CPT_CD,  
	PATNT_ENCNTR_KEY [decimal], --PX_PATNT_ENCNTR_KEY_XREF.PATNT_ENCNTR_KEY,  
	PROVIDR_KEY [int] -- PX_ALL_PROVIDERS.PROVIDR_KEY
) ON [fg_user1]


DROP TABLE IF EXISTS [stage].PROCEDURE_ICD
CREATE TABLE [stage].PROCEDURE_ICD(
	PATIENT_KEY [int], --PX_ALL_PATIENTS.PATNT_KEY,  
	START_DATE [date]  ,--PROCEDURE_EVENT_DTL.START_DATE,  
	PROCEDURE_TYPE [varchar] (50),--PROCEDURE_EVENT_DTL.PROCEDURE_TYPE,  
	PROC_CD_DECML [varchar] (8),--ALL_ICD_PROCEDURE_CODES.PROC_CD_DECML,  
	ICD_TYPE [varchar] (10), --ALL_ICD_PROCEDURE_CODES.ICD_TYPE,  
	PATNT_ENCNTR_KEY [decimal], --PX_PATNT_ENCNTR_KEY_XREF.PATNT_ENCNTR_KEY 
	PROVIDR_KEY [int] --PX_ALL_PROVIDERS.PROVIDR_KEY,  
) ON [fg_user1]


--DROP TABLE [stage].	VISIT
--CREATE TABLE [stage].VISIT(
--	ENCNTR_CSN_ID [decimal] , --PATNT_ENCNTR_KEY_XREF1.ENCNTR_CSN_I,  
--	ADMIT_SOURCES [varchar] (254)  ,--ALL_ADMIT_SOURCES.STNDRD_LABE,  
--	DISCHARGE_DISPOSITIONS [varchar] (254),--ALL_DISCHARGE_DISPOSITIONS.STNDRD_LABELE,  
--	PATIENT_KEY [int]--ALL_PATIENTS.PATNT_KEY 
--) ON [fg_user1]


DROP TABLE IF EXISTS [stage].DRUG_ORDER
CREATE TABLE [stage].DRUG_ORDER(
	PATIENT_KEY [int], --PX_ALL_PATIENTS.PATNT_KEY,  
	MED_ORDER_START_DATE [date]  ,--PROCEDURE_EVENT_DTL.START_DATE,  
	MED_ORDER_START_DATETIME [datetime2],--PROCEDURE_EVENT_DTL.PROCEDURE_TYPE,  
	MED_ORDER_END_DATE [date],--ALL_ICD_PROCEDURE_CODES.PROC_CD_DECML,  
	MED_ORDER_END_DATETIME [datetime2], --ALL_ICD_PROCEDURE_CODES.ICD_TYPE,  
	MED_ORDER_DISCRETE_DOSE [varchar] (50), --PX_PATNT_ENCNTR_KEY_XREF.PATNT_ENCNTR_KEY 
	MED_ORDER_DISCRETE_DOSE_UNIT [varchar] (50),
	RXNORM_CODE [varchar] (50),
	MED_ORDER_QTY [varchar] (50),
	MED_ORDER_REFILLS [varchar] (50),
	MED_ORDER_ROUTE [varchar] (50),
	MED_ORDER_SIG [varchar] (250),
	MED_ORDER_AUTH_PROV_KEY [decimal],
	PATNT_ENCNTR_KEY [decimal]
) ON [fg_user1]

DROP TABLE IF EXISTS [stage].DRUG_ADMIN
CREATE TABLE [stage].DRUG_ADMIN(
	PATIENT_KEY [int], 
	MAR_ACTION [varchar] (200)  ,
	RXNORM_CODE [varchar] (100),
	MED_ORDER_ROUTE [varchar] (100),
	TAKEN_DATE [date], 
	TAKEN_DATETIME [datetime2] ,
	TOTAL_DOSE_CHAR [varchar] (100),
	MED_DOSE_UNIT_DESC [varchar] (100),
	MED_ORDER_AUTH_PROV_KEY [decimal], 
	PATNT_ENCNTR_KEY [decimal] 
) ON [fg_user1]


DROP TABLE IF EXISTS [stage].MEASUREMENT_Res_Device
CREATE TABLE [stage].MEASUREMENT_Res_Device(
	PATIENT_KEY [int], --PX_ALL_PATIENTS.PATNT_KEY,  
	PATNT_ENCNTR_KEY [decimal] null, --PX_PATNT_ENCNTR_KEY_XREF.PATNT_ENCNTR_KEY 
	Respiratory_Device [varchar] (50) null,
	Respiratory_Date [date] NULL,
	Respiratory_Datetime [datetime2] NULL,
	Attending_Provider [int] null,
	Visit_Provider [int] null
) ON [fg_user1]

DROP TABLE IF EXISTS [stage].MEASUREMENT_Res_ETCO2
CREATE TABLE [stage].MEASUREMENT_Res_ETCO2(
	PATIENT_KEY [int], --PX_ALL_PATIENTS.PATNT_KEY,  
	PATNT_ENCNTR_KEY [decimal] null, --PX_PATNT_ENCNTR_KEY_XREF.PATNT_ENCNTR_KEY 
	Respiratory_Date [date] NULL,
	Respiratory_Datetime [datetime2] NULL,
	ETCO2 [int] null,
	ETCO2_Oral_Nasal [int] null,
	Attending_Provider [int] null,
	Visit_Provider [int] null
) ON [fg_user1]

DROP TABLE IF EXISTS [stage].MEASUREMENT_Res_FIO2
CREATE TABLE [stage].MEASUREMENT_Res_FIO2(
	PATIENT_KEY [int], --PX_ALL_PATIENTS.PATNT_KEY,  
	PATNT_ENCNTR_KEY [decimal] null, --PX_PATNT_ENCNTR_KEY_XREF.PATNT_ENCNTR_KEY 
	Respiratory_Date [date] NULL,
	Respiratory_Datetime [datetime2] NULL,
	FIO2 [int] null,
	Attending_Provider [int] null,
	Visit_Provider [int] null
) ON [fg_user1]



DROP TABLE IF EXISTS [stage].OBSERVATION_Smoking
CREATE TABLE [stage].OBSERVATION_Smoking(
	PATIENT_KEY [int], --PX_ALL_PATIENTS.PATNT_KEY,  
	Smoking_Status [varchar] (50),
	Encounter_Effective_Date [date] NULL,
	PATNT_ENCNTR_KEY [decimal] null, --PX_PATNT_ENCNTR_KEY_XREF.PATNT_ENCNTR_KEY 
	Attending_Provider [int] null,
	Visit_Provider [int] null
) ON [fg_user1]


DROP TABLE IF EXISTS [stage].MEASUREMENT_Res_O2
CREATE TABLE [stage].MEASUREMENT_Res_O2(
	PATIENT_KEY [int],   
	PATNT_ENCNTR_KEY [decimal] null,  
	Respiratory_Date [date] NULL,
	Respiratory_Datetime [datetime2] NULL,
	O2_Lmin [decimal] null,
	O2_mLmin [decimal] null,
	Attending_Provider [int] null,
	Visit_Provider [int] null
) ON [fg_user1]


DROP TABLE IF EXISTS [stage].MEASUREMENT_Res_GCS
CREATE TABLE [stage].MEASUREMENT_Res_GCS(
	PATIENT_KEY [int], 
	PATNT_ENCNTR_KEY [decimal] null, 
	Respiratory_Date [date] NULL,
	Respiratory_Datetime [datetime2] NULL,
	Glasgow_Coma_Peds_Score [decimal],
	Glasgow_Coma_Adult_Score [decimal],
	Attending_Provider [decimal] null,
	Visit_Provider [decimal] null
) ON [fg_user1]


DROP TABLE IF EXISTS [stage].MEASUREMENT_Res_PEEP
CREATE TABLE [stage].MEASUREMENT_Res_PEEP(
	PATIENT_KEY [int], 
	PATNT_ENCNTR_KEY [decimal] null, 
	Respiratory_Date [date] NULL,
	Respiratory_Datetime [datetime2] NULL,
	PEEP [decimal] NULL,
	Attending_Provider [decimal] null,
	Visit_Provider [decimal] null
) ON [fg_user1]

DROP TABLE IF EXISTS [stage].MEASUREMENT_Res_PIP
CREATE TABLE [stage].MEASUREMENT_Res_PIP(
	PATIENT_KEY [int], 
	PATNT_ENCNTR_KEY [decimal] null, 
	Respiratory_Date [date] NULL,
	Respiratory_Datetime [datetime2] NULL,
	PIP [varchar] (200) NULL,
	Attending_Provider [decimal] null,
	Visit_Provider [decimal] null
) ON [fg_user1]

DROP TABLE IF EXISTS [stage].MEASUREMENT_Res_PIP
CREATE TABLE [stage].MEASUREMENT_Res_PIP(
	PATIENT_KEY [int], 
	PATNT_ENCNTR_KEY [decimal] null, 
	Respiratory_Date [date] NULL,
	Respiratory_Datetime [datetime2] NULL,
	PIP [varchar] (200) NULL,
	Attending_Provider [decimal] null,
	Visit_Provider [decimal] null
) ON [fg_user1]


DROP TABLE IF EXISTS [stage].MEASUREMENT_Res_RESP
CREATE TABLE [stage].MEASUREMENT_Res_RESP(
	PATIENT_KEY [int], 
	PATNT_ENCNTR_KEY [decimal] null, 
	Respiratory_Date [date] NULL,
	Respiratory_Datetime [datetime2] NULL,
	Adult_Mech_Resp_Rate [varchar] (100) NULL,
	Adult_Spont_Resp_Rate [decimal] null, 
	Peds_Mech_Resp_Rate [decimal] null, 
	Peds_Spont_Resp_Rate [decimal] null, 
	Respiratory_Device [varchar] (100) NULL,
	Respiratory_Rate [varchar] (100) NULL,
	Attending_Provider [decimal] null,
	Visit_Provider [decimal] null,
	Adult_Vent_Mode [varchar] (100) NULL,
	Adult_Vent_Start_Time [varchar] (100) NULL,
	Adult_Vent_End_Time [varchar] (100) NULL,
	Peds_Vent_Mode [varchar] (100) NULL,
	Peds_Vent_Start_Time [varchar] (100) NULL,
	Peds_Vent_End_Time [varchar] (100) NULL,
	Encounter_Number_CSN [decimal] null
) ON [fg_user1]


DROP TABLE IF EXISTS [stage].MEASUREMENT_Res_SPO2
CREATE TABLE [stage].MEASUREMENT_Res_SPO2(
	PATIENT_KEY [int], 
	PATNT_ENCNTR_KEY [decimal] null, 
	Respiratory_Date [date] NULL,
	Respiratory_Datetime [datetime2] NULL,
	SPO2 [decimal] NULL,
	Attending_Provider [decimal] null,
	Visit_Provider [decimal] null
) ON [fg_user1]



DROP TABLE IF EXISTS [stage].MEASUREMENT_Res_Tidal
CREATE TABLE [stage].MEASUREMENT_Res_Tidal(
	PATIENT_KEY [int], 
	PATNT_ENCNTR_KEY [decimal] null, 
	Respiratory_Date [date] NULL,
	Respiratory_Datetime [datetime2] NULL,
	Tidal_Volume [decimal] null,
	Tidal_Volume_Exhaled [varchar] (100) NULL,
	Attending_Provider [decimal] null,
	Visit_Provider [decimal] null
) ON [fg_user1]



DROP TABLE IF EXISTS [stage].MEASUREMENT_Res_Vent
CREATE TABLE [stage].MEASUREMENT_Res_Vent(
	PATIENT_KEY [int], 
	PATNT_ENCNTR_KEY [decimal] null, 
	Respiratory_Date [date] NULL,
	Respiratory_Datetime [datetime2] NULL,
	Peds_Vent_Mode [varchar] (100) NULL,
	Adult_Vent_Mode [varchar] (100) NULL,
	Attending_Provider [decimal] null,
	Visit_Provider [decimal] null
) ON [fg_user1]


DROP TABLE IF EXISTS [stage].MEASUREMENT_LAB
CREATE TABLE [stage].MEASUREMENT_LAB(
	PATIENT_KEY [int], 
	PATNT_ENCNTR_KEY [decimal] null, 
	NORMAL_LOW [varchar] (150) NULL,
	NORMAL_HIGH [varchar] (150) NULL,
	INFERRED_LOINC_CODE [varchar] (150) NULL,
	LAB_UNIT [varchar] (150) NULL,
	LAB_RESULT [varchar] (max) NULL,
	SPECIMEN_TAKEN_DATE [date]  NULL,
	SPECIMEN_TAKEN_TIME [varchar] (150) NULL,
	SPECIMEN_TAKEN_DATETIME [datetime2]  NULL,
	INFERRED_SPECIMEN_DATE [date] NULL,
	INFERRED_SPECIMEN_TIME [varchar] (150) NULL,
	INFERRED_SPECIMEN_DATETIME [datetime2] NULL,
	Attending_Provider [decimal] null
) ON [fg_user1]

DROP TABLE IF EXISTS [stage].MEASUREMENT_BP
CREATE TABLE [stage].MEASUREMENT_BP(
	PATIENT_KEY [int], 
	PATNT_ENCNTR_KEY [decimal] null, 
	BP_DATE [date] NULL,
	BP_DATETIME [datetime2] NULL,
	BP [varchar] (100) NULL,
	SYSTOLIC [decimal] null,
	DIASTOLIC [decimal] null,
	BP_NON_INVASIVE [varchar] (100) NULL,
	ARTERIAL_LINE [varchar] (100) NULL,
	CVP [decimal] null,
	CVP_MEAN [varchar] (100) NULL,
	MAP_A_LINE [decimal] null,
	MAP_CUFF [decimal] null,
	MAP_NON_INVASIVE [varchar] (100) NULL,
	PAP_MEAN [varchar] (100) NULL,
	Attending_Provider [decimal] null,
	Visit_Provider [decimal] null
) ON [fg_user1]


DROP TABLE IF EXISTS [stage].MEASUREMENT_HeartRate
CREATE TABLE [stage].MEASUREMENT_HeartRate(
	PATIENT_KEY [int], 
	PATNT_ENCNTR_KEY [decimal] null, 
	VITALS_Date [date] NULL,
	VITALS_Datetime [datetime2] NULL,
	PIP [varchar] (200) NULL,
	Attending_Provider [decimal] null,
	Visit_Provider [decimal] null
) ON [fg_user1]


DROP TABLE IF EXISTS [stage].MEASUREMENT_Height
CREATE TABLE [stage].MEASUREMENT_Height(
	PATIENT_KEY [int], 
	PATNT_ENCNTR_KEY [decimal] null, 
	HIGHT_Date [date] NULL,
	HIGHT_Datetime [datetime2] NULL,
	HIGH_INCH [decimal] null,
	HIGH_CM [decimal] null,
	Attending_Provider [decimal] null,
	Visit_Provider [decimal] null
) ON [fg_user1]

DROP TABLE IF EXISTS [stage].MEASUREMENT_LDA
CREATE TABLE [stage].MEASUREMENT_LDA(
	PATIENT_KEY [int], 
	Intubation_Dt [datetime2] NULL,
	Extubation_Dt [datetime2] NULL,
	PATNT_ENCNTR_KEY [decimal] null, 
	Airway_Display_Name [varchar] (200) NULL,
	Attending_Provider [decimal] null,
	Visit_Provider [decimal] null
) ON [fg_user1]


DROP TABLE IF EXISTS [stage].MEASUREMENT_PainScale
CREATE TABLE [stage].MEASUREMENT_PainScale(
	PATIENT_KEY [int], 
	PATNT_ENCNTR_KEY [decimal] null, 
	PAIN_DATE [date] NULL,
	PAIN_DATETIME [datetime2] NULL,
	PAIN_UF_DVPRS [varchar] (100) null, 
	Pain_Peds_Wong_Baker [varchar] (100) null, 
	Pain_JAX [varchar] (100) null, 
	Attending_Provider [decimal] null,
	Visit_Provider [decimal] null
) ON [fg_user1]

DROP TABLE IF EXISTS [stage].MEASUREMENT_QTCB
CREATE TABLE [stage].MEASUREMENT_QTCB(
	PATIENT_KEY [int], 
	PATNT_ENCNTR_KEY [decimal] null, 
	ECG_Acq_Date [datetime2] NULL,
	ECG_Acq_Time [varchar] (100) null,
	QTCB [decimal] null,
	Attending_Provider [decimal] null,
	Visit_Provider [decimal] null
) ON [fg_user1]


DROP TABLE IF EXISTS [stage].MEASUREMENT_Weight
CREATE TABLE [stage].MEASUREMENT_Weight(
	PATIENT_KEY [int], 
	PATNT_ENCNTR_KEY [decimal] null, 
	Weight_Date [datetime2] NULL,
	Weight_Datetime [datetime2] null,
	Weight_kgs [decimal] null, 
	Weight_lbs [decimal] null, 
	Attending_Provider [decimal] null,
	Visit_Provider [decimal] null
) ON [fg_user1]



DROP TABLE IF EXISTS [stage].MEASUREMENT_Temp
CREATE TABLE [stage].MEASUREMENT_Temp(
	PATIENT_KEY [int], 
	PATNT_ENCNTR_KEY [decimal] null, 
	Vitals_Date [datetime] NULL,
	Vitals_Datetime [datetime2] null,
	Temp_Farenheit [decimal] null, 
	Temp_Celsius [decimal] null, 
	Attending_Provider [decimal] null,
	Visit_Provider [decimal] null
) ON [fg_user1]


DROP TABLE IF EXISTS [stage].MEASUREMENT_Rothman
CREATE TABLE [stage].MEASUREMENT_Rothman(
	PATIENT_KEY [int], 
	PATNT_ENCNTR_KEY [decimal] null, 
	Rothman_Index_Date [datetime2] NULL,
	Rothman_Index_Datetime [datetime2] null,
	Rothman_Index_Score [varchar] (250) null,
	Attending_Provider [decimal] null,
	Visit_Provider [decimal] null
) ON [fg_user1]

DROP TABLE IF EXISTS [stage].MEASUREMENT_SOFA
CREATE TABLE [stage].MEASUREMENT_SOFA(
	PATIENT_KEY [int], 
	PATNT_ENCNTR_KEY [decimal] null, 
	Date_of_care [datetime2] null,
	SOFA_Score [decimal] null,
	Cardiovascular [decimal] null,
	CNS [decimal] null,
	Coagulation [decimal] null,
	Liver [decimal] null,
	Renal [decimal] null,
	Respiration [decimal] null,
	Attending_Provider [decimal] null,
	Visit_Provider [decimal] null
) ON [fg_user1]


DROP TABLE IF EXISTS [stage].OBSERVATION_Payer
CREATE TABLE [stage].OBSERVATION_Payer(
	PATIENT_KEY [int], 
	Encounter_Effective_Date [datetime2] null,
	Payer [varchar] (250) null,
	PATNT_ENCNTR_KEY [decimal] null, 
	Attending_Provider [int] null,
	Visit_Provider [int] null
) ON [fg_user1]


DROP TABLE IF EXISTS [stage].OBSERVATION_ICU
CREATE TABLE [stage].OBSERVATION_ICU(
	PATIENT_KEY [int], 
	Encounter_Effective_Date [datetime2] null,
	ICU_Stay [varchar] (50) null,
	ICU_Days [decimal] null, 
	PATNT_ENCNTR_KEY [decimal] null, 
	Attending_Provider [int] null,
	Visit_Provider [int] null
) ON [fg_user1]


DROP TABLE IF EXISTS [stage].OBSERVATION_Zipcode
CREATE TABLE [stage].OBSERVATION_Zipcode(
	PATIENT_KEY [int], 
	Encounter_Effective_Date [datetime2] null,
	ZIP [varchar] (50) null,
	PATNT_ENCNTR_KEY [decimal] null, 
	Attending_Provider [int] null,
	Visit_Provider [int] null
) ON [fg_user1]