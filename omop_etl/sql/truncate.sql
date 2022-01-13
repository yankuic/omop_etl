--truncate cohort tables (note: each project has a set of tables in cohort schema in addition to PersonList. They have to be truncated using a different script.)
truncate table cohort.PersonList

--truncate all dbo tables
truncate table dbo.attribute_definition
truncate table dbo.care_site
truncate table dbo.cdm_source
truncate table dbo.cohort_definition
truncate table dbo.condition_era
truncate table dbo.condition_occurrence
truncate table dbo.cost
truncate table dbo.death
truncate table dbo.device_exposure
truncate table dbo.dose_era
truncate table dbo.drug_era
truncate table dbo.drug_exposure
truncate table dbo.fact_relationship
truncate table dbo.location
truncate table dbo.measurement
truncate table dbo.metadata
truncate table dbo.note
truncate table dbo.note_nlp
truncate table dbo.observation
truncate table dbo.observation_period
truncate table dbo.payer_plan_period
truncate table dbo.person
truncate table dbo.procedure_occurrence
truncate table dbo.provider
truncate table dbo.specimen
truncate table dbo.visit_detail
truncate table dbo.visit_occurrence

--truncate all hipaa tables
--truncate table hipaa.attribute_definition
truncate table hipaa.care_site
--truncate table hipaa.cdm_source
--truncate table hipaa.cohort_definition
truncate table hipaa.condition_era
truncate table hipaa.condition_occurrence
--truncate table hipaa.cost
truncate table hipaa.death
truncate table hipaa.device_exposure
--truncate table hipaa.dose_era
truncate table hipaa.drug_era
truncate table hipaa.drug_exposure
--truncate table hipaa.fact_relationship
truncate table hipaa.location
truncate table hipaa.measurement
--truncate table hipaa.metadata
truncate table hipaa.note
--truncate table hipaa.note_nlp
truncate table hipaa.observation
truncate table hipaa.observation_period
--truncate table hipaa.payer_plan_period
truncate table hipaa.person
truncate table hipaa.procedure_occurrence
truncate table hipaa.provider
--truncate table hipaa.specimen
--truncate table hipaa.visit_detail
truncate table hipaa.visit_occurrence

--truncate all preload tables
truncate table preload.condition_occurrence
truncate table preload.drug_exposure
truncate table preload.measurement
truncate table preload.observation
truncate table preload.procedure_occurrence

--truncate all stage tables
truncate table stage.care_site
truncate table stage.condition
truncate table stage.condition_admit_icd10
truncate table stage.condition_admit_icd9
truncate table stage.condition_principal_icd10
truncate table stage.condition_principal_icd9
truncate table stage.death
truncate table stage.drug_admin
truncate table stage.drug_order
truncate table stage.location
truncate table stage.measurement_bp_arterialLine
truncate table stage.measurement_bp_bp
truncate table stage.measurement_bp_bp_nonInvasive
truncate table stage.measurement_bp_cvp
truncate table stage.measurement_bp_cvp_mean
truncate table stage.measurement_bp_map_A_line
truncate table stage.measurement_bp_map_cuff
truncate table stage.measurement_bp_map_noninvasive
truncate table stage.measurement_bp_pap_mean
truncate table stage.measurement_gcs
truncate table stage.measurement_gcs_peds
truncate table stage.measurement_heartRate
truncate table stage.measurement_height
truncate table stage.measurement_lab
truncate table stage.measurement_painScale
truncate table stage.measurement_painScale_JAX
truncate table stage.measurement_painScale_peds
truncate table stage.measurement_qtcb
truncate table stage.measurement_res_device
truncate table stage.measurement_res_etco2
truncate table stage.measurement_res_etco2_no
truncate table stage.measurement_res_fio2
truncate table stage.measurement_res_o2
truncate table stage.measurement_res_o2_ml
truncate table stage.measurement_res_peep
truncate table stage.measurement_res_pip
truncate table stage.measurement_res_resp
truncate table stage.measurement_res_resp_AdultSpont
truncate table stage.measurement_res_resp_MechVentSetRate
truncate table stage.measurement_res_resp_PedsSpont
truncate table stage.measurement_res_spo2
truncate table stage.measurement_res_Tidal
truncate table stage.measurement_res_Tidal_Mech
truncate table stage.measurement_res_Tidal_Spont
truncate table stage.measurement_res_Vent_End
truncate table stage.measurement_res_Vent_End_Peds
truncate table stage.measurement_res_Vent_Mode
truncate table stage.measurement_res_Vent_Mode_Peds
truncate table stage.measurement_res_Vent_Start
truncate table stage.measurement_res_Vent_Start_Peds	
truncate table stage.measurement_Rothman
truncate table stage.measurement_SOFA
truncate table stage.measurement_Temp
truncate table stage.measurement_Weight
truncate table stage.observation_ICU
truncate table stage.observation_LDA
truncate table stage.observation_Payer
truncate table stage.observation_Smoking
truncate table stage.observation_Vent
truncate table stage.observation_Zipcode
truncate table stage.person
truncate table stage.procedure_CPT
truncate table stage.procedure_ICD
truncate table stage.provider
truncate table stage.visit

--ref schema is not truncated because
--  *mapping is kept from one data refresh to the next, so we just want to update mappings in each refresh.
--  *vocabulary tables are truncated only when new vocabulary is uploaded.
