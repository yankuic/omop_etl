insert into @Schema.drug_exposure with (tablock) (
      @TableId
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
select @TableId 
      a.person_id
      ,drug_concept_id
      ,drug_exposure_start_date = dateadd(day, @DateShift, a.drug_exposure_start_date)
      ,drug_exposure_start_datetime = dateadd(day, @DateShift, a.drug_exposure_start_datetime)
      ,drug_exposure_end_date = dateadd(day, @DateShift, a.drug_exposure_end_date)
      ,drug_exposure_end_datetime = dateadd(day, @DateShift, a.drug_exposure_end_datetime)
      ,verbatim_end_date = dateadd(day, @DateShift, a.verbatim_end_date)
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
from @FromSchema.drug_exposure a 
join xref.person_mapping b
on a.person_id = b.person_id 
where b.active_ind = 'Y'
