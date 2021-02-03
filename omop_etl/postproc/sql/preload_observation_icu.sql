insert into preload.observation with (tablock)
select person_id = b.person_id
      ,observation_concept_id = d.target_concept_id
      ,observation_date = a.Encounter_Effective_Date
      ,observation_datetime = a.Encounter_Effective_Date
      ,observation_type_concept_id = 32817
      ,value_as_number = a.ICU_Days
      ,value_as_string = a.ICU_Stay
      ,value_as_concept_id = NULL
      ,qualifier_concept_id = NULL
      ,unit_concept_id = 8512
      ,provider_id = c.provider_id
      ,visit_occurrence_id = e.visit_occurrence_id
      ,visit_detail_id = NULL
      ,observation_source_value = d.source_code
      ,observation_source_concept_id = d.source_concept_id
      ,unit_source_value = 'days'
      ,qualifier_source_value = NULL
      ,source_table = 'observation_icu'
from stage.observation_icu a 
join xref.person_mapping b
on a.patient_key = b.patient_key
join xref.provider c 
on c.provider_source_value = isnull(a.Attending_Provider, a.Visit_Provider)
left join xref.source_to_concept_map d 
on source_code = 'ICU stay Y/N' and source_vocabulary_id = 'observation'
join xref.visit_occurrence_mapping e
on a.patnt_encntr_key = g.patnt_encntr_key