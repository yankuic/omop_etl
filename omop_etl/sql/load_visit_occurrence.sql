insert into dbo.visit_occurrence with (tablock)
select visit_occurrence_id = b.visit_occurrence_id
      ,person_id = c.person_id
      ,visit_concept_id = g.target_concept_id
      ,visit_start_date = a.ENCOUNTER_EFFECTIVE_DATE
      ,visit_start_datetime = a.ENCOUNTER_EFFECTIVE_DATE
      ,visit_end_date = isnull(a.DISCHG_DATE, a.ENCOUNTER_EFFECTIVE_DATE)
      ,visit_end_datetime = isnull(a.DISCHG_DATETIME, a.ENCOUNTER_EFFECTIVE_DATE)
      ,visit_type_concept_id = 32817
      ,provider_id = d.provider_id
      ,care_site_id = h.care_site_id
--      ,a.patient_type,a.encounter_type,a.hospital,a.location_of_service,a.ed_episode_id
      ,visit_source_value = case
		when a.encounter_type='Telephone' then 'telephone'
		when a.encounter_type='Telemedicine' then 'telemedicine'
		when (a.hospital in ('UFHP CLINIC','UFJP CLINIC','UFCP CLINIC') and (a.encounter_type not in ('Erroneous Encounter','Telephone','Telemedicine'))) then 'clinic visit'
		when (a.location_of_service in ('UF CARE ONE CLINIC') and (a.encounter_type not in ('Erroneous Encounter','Telephone','Telemedicine'))) then 'clinic visit'
		when a.encounter_type in ('APPOINTMENT','OFFICE VISIT') then 'clinic visit'
		when (a.patient_type in ('INPATIENT') and a.ed_episode_id is NULL) then 'inpatient'
		when (a.patient_type in ('INPATIENT') and a.ed_episode_id is not NULL) then 'inpatient ED'
		when (a.patient_type in ('OUTPATIENT','RECURRING OUTPATIENT') and a.ed_episode_id is NULL) then 'hospital outpatient'
		when (a.patient_type in ('OUTPATIENT','RECURRING OUTPATIENT') and a.ed_episode_id is not NULL) then 'ED treat & release'
		when (a.patient_type in ('EMERGENCY')) then 'ED treat & release'
		when (a.patient_type in ('OBSERVATION') and a.ed_episode_id is NULL) then 'observation'
		when (a.patient_type in ('OBSERVATION') and a.ed_episode_id is not NULL) then 'observation ED'
		when (a.patient_type in ('AMBULATORY SURGERY')) then 'ambulatory surgery'
		else 'unknown'
		end
--      ,visit_source_concept_id = g.source_concept_id
	  ,visit_source_concept_id = case
		when a.encounter_type='Telephone' then 5083 -- telemedicine
		when a.encounter_type='Telemedicine' then 5083 -- telemedicine
		when (a.hospital in ('UFHP CLINIC','UFJP CLINIC','UFCP CLINIC') and (a.encounter_type not in ('Erroneous Encounter','Telephone','Telemedicine'))) then 9202 --clinic visit
		when (a.location_of_service in ('UF CARE ONE CLINIC') and (a.encounter_type not in ('Erroneous Encounter','Telephone','Telemedicine'))) then 9202 --clinic visit
		when a.encounter_type in ('APPOINTMENT','OFFICE VISIT') then 9202 --clinic visit
		when (a.patient_type in ('INPATIENT') and a.ed_episode_id is NULL) then 8717 --inpatient
		when (a.patient_type in ('INPATIENT') and a.ed_episode_id is not NULL) then 262 --inpatient ED
		when (a.patient_type in ('OUTPATIENT','RECURRING OUTPATIENT') and a.ed_episode_id is NULL) then 8756 --hospital outpatient
		when (a.patient_type in ('OUTPATIENT','RECURRING OUTPATIENT') and a.ed_episode_id is not NULL) then 9203 --ED treat & release
		when (a.patient_type in ('EMERGENCY')) then 9203 --ED treat & release
		when (a.patient_type in ('OBSERVATION') and a.ed_episode_id is NULL) then 581385 --observation
		when (a.patient_type in ('OBSERVATION') and a.ed_episode_id is not NULL) then 581385 --observation ED
		when (a.patient_type in ('AMBULATORY SURGERY')) then 8883 --ambulatory surgery
		else 0 --unknown
		end
	  ,admitting_source_concept_id =  e.source_concept_id
      ,admitting_source_value = a.ADMIT_SOURCES
      ,discharge_to_concept_id = f.source_concept_id
      ,discharge_to_source_value = a.DISCHG_DISPOSITION
      ,preceding_visit_occurrence_id = NULL
from stage.visit a 
join xref.visit_occurrence_mapping b 
on a.patnt_encntr_key = b.patnt_encntr_key
join xref.person_mapping c
on a.patient_key = c.patient_key
left join xref.provider_mapping d
on d.providr_key = isnull(a.attending_provider, a.VISIT_PROVIDER) and d.providr_key > 0
left join xref.source_to_concept_map e 
on a.ADMIT_SOURCES = e.source_code and e.source_vocabulary_id = 'Admit Source'
left join xref.source_to_concept_map f 
on a.DISCHG_DISPOSITION = f.source_code and f.source_vocabulary_id = 'Discharge Dis'
left join xref.source_to_concept_map g
on a.PATIENT_TYPE = g.source_code and g.source_vocabulary_id = 'Patient Type'
left join xref.care_site_mapping h
on h.dept_id = a.dept_id
where c.active_ind = 'Y'
