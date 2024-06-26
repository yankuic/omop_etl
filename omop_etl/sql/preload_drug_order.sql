-- truncate table preload.drug_order
insert into preload.drug_exposure with (tablock)
select [person_id] = b.person_id
      ,[drug_concept_id] = isnull(e.concept_id_2,0)
      ,[drug_exposure_start_date] = a.MED_ORDER_START_DATE
      ,[drug_exposure_start_datetime] = a.MED_ORDER_START_DATETIME
      ,[drug_exposure_end_date] = ISNULL(a.MED_ORDER_END_DATE, a.MED_ORDER_START_DATE)
      ,[drug_exposure_end_datetime] = ISNULL(a.MED_ORDER_END_DATETIME, a.MED_ORDER_START_DATETIME)
      ,[verbatim_end_date] = a.MED_ORDER_END_DATE
      ,[drug_type_concept_id] = 32833
      ,[stop_reason] = NULL
      ,[refills] = try_convert(INT, a.MED_ORDER_REFILLS)
      ,[quantity] = (case 
                        when try_convert(INT, a.MED_ORDER_QTY) is null
                          -- or try_convert(NUMERIC(18,4), a.MED_ORDER_QTY) is null 
                          -- or try_convert(FLOAT, a.MED_ORDER_QTY) is null 
                        then REPLACE(SUBSTRING(a.MED_ORDER_QTY, PATINDEX('%[0-9]%', a.MED_ORDER_QTY), PATINDEX('%[ -a-z]%', a.MED_ORDER_QTY)-1), ',', '')
                        else a.MED_ORDER_QTY
                     end)
      ,[days_supply] = NULL
      ,[sig] = a.MED_ORDER_SIG
      ,[route_concept_id] = NULL
      ,[lot_number] = NULL
      ,[provider_id] = c.provider_id
      ,[visit_occurrence_id] = isnull(h.visit_occurrence_id,g.visit_occurrence_id) 
      ,[visit_detail_id] = h.visit_detail_id
      ,[drug_source_value] = a.RXNORM_CODE
      ,[drug_source_concept_id] = d.concept_id
      ,[route_source_value] = a.MED_ORDER_ROUTE
      ,[dose_unit_source_value] = a.MED_ORDER_DISCRETE_DOSE_UNIT
      ,[source_table] = 'drug_order'
from stage.drug_order a
join xref.person_mapping b
on a.patient_key = b.patient_key
left join xref.provider_mapping c 
on c.providr_key = a.provider_key and c.providr_key > 0
left join xref.concept d
on a.RXNORM_CODE = d.concept_code and d.vocabulary_id like 'rxnorm%'
join xref.concept_relationship e
on d.concept_id = e.concept_id_1 and e.relationship_id = 'Maps to'
-- join xref.concept f
-- on e.concept_id_2 = f.concept_id and f.domain_id = 'Drug'
left join xref.visit_occurrence_mapping g
on a.patnt_encntr_key = g.patnt_encntr_key
left join xref.visit_detail_mapping h
on a.patnt_encntr_key = h.patnt_encntr_key
where b.active_ind = 'Y'
