--truncate archive_xref tables 
truncate table archive_xref.care_site_mapping
truncate table archive_xref.location_mapping
truncate table archive_xref.provider_mapping
truncate table archive_xref.person_mapping
truncate table archive_xref.visit_occurrence_mapping

--archive xref mapping tables
insert into archive_xref.care_site_mapping select * from xref.care_site_mapping
insert into archive_xref.location_mapping select * from xref.location_mapping
insert into archive_xref.provider_mapping select * from xref.provider_mapping
insert into archive_xref.person_mapping select * from xref.person_mapping
insert into archive_xref.visit_occurrence_mapping select * from xref.visit_occurrence_mapping


--truncate archive tables
truncate table archive.attribute_definition
truncate table archive.care_site
truncate table archive.cdm_source
truncate table archive.cohort_definition
truncate table archive.condition_era
truncate table archive.condition_occurrence
truncate table archive.cost
truncate table archive.death
truncate table archive.device_exposure
truncate table archive.dose_era
truncate table archive.drug_era
truncate table archive.drug_exposure
truncate table archive.fact_relationship
truncate table archive.location
truncate table archive.measurement
truncate table archive.metadata
truncate table archive.note
truncate table archive.note_nlp
truncate table archive.observation
truncate table archive.observation_period
truncate table archive.payer_plan_period
truncate table archive.person
truncate table archive.procedure_occurrence
truncate table archive.provider
truncate table archive.specimen
truncate table archive.visit_detail
truncate table archive.visit_occurrence

--archive dbo tables
insert into archive.attribute_definition select * from dbo.attribute_definition
insert into archive.care_site select * from dbo.care_site
insert into archive.cdm_source select * from dbo.cdm_source
insert into archive.cohort_definition select * from dbo.cohort_definition
insert into archive.condition_era select * from dbo.condition_era
insert into archive.condition_occurrence select * from dbo.condition_occurrence
insert into archive.cost select * from dbo.cost
insert into archive.death select * from dbo.death
insert into archive.device_exposure select * from dbo.device_exposure
insert into archive.dose_era select * from dbo.dose_era
insert into archive.drug_era select * from dbo.drug_era
insert into archive.drug_exposure select * from dbo.drug_exposure
insert into archive.fact_relationship select * from dbo.fact_relationship
insert into archive.location select * from dbo.location
insert into archive.measurement select * from dbo.measurement
insert into archive.metadata select * from dbo.metadata
insert into archive.note select * from dbo.note
insert into archive.note_nlp select * from dbo.note_nlp
insert into archive.observation select * from dbo.observation
insert into archive.observation_period select * from dbo.observation_period
insert into archive.payer_plan_period select * from dbo.payer_plan_period
insert into archive.person select * from dbo.person
insert into archive.procedure_occurrence select * from dbo.procedure_occurrence
insert into archive.provider select * from dbo.provider
insert into archive.specimen select * from dbo.specimen
insert into archive.visit_detail select * from dbo.visit_detail
insert into archive.visit_occurrence select * from dbo.visit_occurrence
