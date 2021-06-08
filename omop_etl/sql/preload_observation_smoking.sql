insert into preload.observation with (tablock)
select person_id = b.person_id
      ,observation_concept_id = d.target_concept_id
      ,observation_date = a.Encounter_Effective_Date
      ,observation_datetime = a.Encounter_Effective_Date
      ,observation_type_concept_id = 32817
      ,value_as_number = NULL
      ,value_as_string = a.Smoking_Status
      ,value_as_concept_id = NULL
      ,qualifier_concept_id = NULL
      ,unit_concept_id = NULL
      ,provider_id = c.provider_id
      ,visit_occurrence_id = e.visit_occurrence_id
      ,visit_detail_id = NULL
      ,observation_source_value = d.source_code
      ,observation_source_concept_id = d.source_concept_id
      ,unit_source_value = NULL
      ,qualifier_source_value = NULL
      ,source_table = 'observation_smoking'
from stage.observation_smoking a 
join xref.person_mapping b
on a.patient_key = b.patient_key
left join xref.provider_mapping c 
on c.providr_key = isnull(a.Attending_Provider, a.Visit_Provider)
left join xref.source_to_concept_map d 
on source_code = 'SMOKING STATUS' and source_vocabulary_id = 'observation'
left join xref.visit_occurrence_mapping e
on a.patnt_encntr_key = e.patnt_encntr_key
where a.Encounter_Effective_Date is not NULL --is this the right way to enforce constraints?
and b.active_ind = 'Y'
