--truncate table preload.drug_exposure
insert into preload.drug_exposure with (tablock)
select [person_id] = b.person_id
      ,[drug_concept_id] = isnull(e.concept_id_2,0)
      ,[drug_exposure_start_date] = a.TAKEN_DATE
      ,[drug_exposure_start_datetime] = a.TAKEN_DATETIME
      ,[drug_exposure_end_date] = a.TAKEN_DATE
      ,[drug_exposure_end_datetime] = a.TAKEN_DATETIME
      ,[verbatim_end_date] = NULL
      ,[drug_type_concept_id] = 32818
      ,[stop_reason] = NULL
      ,[refills] = NULL
      ,[quantity] = (case when isnumeric(a.TOTAL_DOSE_CHAR) = 0 
                          then REPLACE(SUBSTRING(a.TOTAL_DOSE_CHAR, PATINDEX('%[0-9]%', a.TOTAL_DOSE_CHAR), PATINDEX('%[ -a-z]%', a.TOTAL_DOSE_CHAR)-1), ',','') --This is where things might fail since we might not be capturing all possible cases of 'weird' inputs.
                          else a.TOTAL_DOSE_CHAR
                     end) 
      ,[days_supply] = NULL
      ,[sig] = NULL
      ,[route_concept_id] = NULL
      ,[lot_number] = NULL
      ,[provider_id] = c.provider_id
      ,[visit_occurrence_id] = isnull(h.visit_occurrence_id,g.visit_occurrence_id)
      ,[visit_detail_id] = h.visit_detail_id
      ,[drug_source_value] = a.RXNORM_CODE
      ,[drug_source_concept_id] = d.concept_id
      ,[route_source_value] = a.MED_ORDER_ROUTE
      ,[dose_unit_source_value] = a.MED_DOSE_UNIT_DESC
      ,[source_table] = 'drug_admin'
from stage.drug_admin a
join xref.person_mapping b
on a.patient_key = b.patient_key
left join xref.provider_mapping c 
on c.providr_key = a.provider_key and c.providr_key > 0
left join xref.concept d
on a.RXNORM_CODE = d.concept_code and d.vocabulary_id like 'rxnorm%'
left join xref.concept_relationship e
on d.concept_id = e.concept_id_1 and e.relationship_id = 'Maps to'
-- join xref.concept f
-- on e.concept_id_2 = f.concept_id and f.domain_id = 'Drug'
left join xref.visit_occurrence_mapping g
on a.patnt_encntr_key = g.patnt_encntr_key
left join xref.visit_detail_mapping h
on a.patnt_encntr_key = h.patnt_encntr_key
where b.active_ind = 'Y'
