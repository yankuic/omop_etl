drop index if exists
      [ix_drugconceptid_personid] ON [dbo].[drug_exposure],
      [ix_personid_drugconceptid] ON [dbo].[drug_exposure]

alter table [dbo].[drug_exposure] 
drop constraint if exists [pk_drug_exposure]

insert into dbo.drug_exposure with (tablock) (
       person_id
      ,drug_concept_id
      ,drug_exposure_start_date
      ,drug_exposure_start_datetime
      ,drug_exposure_end_date
      ,drug_exposure_end_datetime
      ,verbatim_end_date
      ,drug_type_concept_id
      ,stop_reason
      ,refills
      ,quantity
      ,days_supply
      ,sig
      ,route_concept_id
      ,lot_number
      ,provider_id
      ,visit_occurrence_id
      ,visit_detail_id
      ,drug_source_value
      ,drug_source_concept_id
      ,route_source_value
      ,dose_unit_source_value 
)
select distinct 
      a.person_id
      ,drug_concept_id
      ,drug_exposure_start_date
      ,drug_exposure_start_datetime
      ,drug_exposure_end_date
      ,drug_exposure_end_datetime
      ,verbatim_end_date
      ,drug_type_concept_id
      ,stop_reason
      ,refills
      ,quantity
      ,days_supply
      ,sig
      ,route_concept_id
      ,lot_number
      ,a.provider_id
      ,visit_occurrence_id
      ,visit_detail_id
      ,drug_source_value
      ,drug_source_concept_id
      ,route_source_value
      ,dose_unit_source_value 
from preload.drug_exposure a 
-- join dbo.person b
-- on a.person_id = b.person_id
-- where visit_occurrence_id is null 
-- or visit_occurrence_id in (
--       select visit_occurrence_id 
--       from dbo.visit_occurrence
-- )

