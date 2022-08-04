insert into preload.observation with (tablock)
select distinct *
from (
      select person_id = b.person_id
            ,observation_concept_id = isnull(d.target_concept_id, 0)
            ,observation_date = cast(a.ENCOUNTER_EFFECTIVE_DATE as date)
            ,observation_datetime = a.ENCOUNTER_EFFECTIVE_DATE
            ,observation_type_concept_id = 32817
            ,value_as_number = NULL
            ,value_as_string = a.vent_invasive
            ,value_as_concept_id = NULL
            ,qualifier_concept_id = NULL
            ,unit_concept_id = NULL
            ,provider_id = c.provider_id
            ,visit_occurrence_id = isnull(f.visit_occurrence_id,e.visit_occurrence_id)
            ,visit_detail_id = f.visit_detail_id
            ,observation_source_value = d.source_code
            ,observation_source_concept_id = isnull(d.source_concept_id, 0)
            ,unit_source_value = NULL
            ,qualifier_source_value = NULL
            ,source_table = 'observation_vent'
      from stage.observation_vent a 
      join xref.person_mapping b
      on a.patient_key = b.patient_key
      left join xref.provider_mapping c 
      on c.providr_key = isnull(a.Attending_Provider, a.Visit_Provider) and c.providr_key > 0
      left join xref.source_to_concept_map d 
      on d.source_code = 'Mechanical vent use - invasive' and d.source_vocabulary_id = 'observation'
      left join xref.visit_occurrence_mapping e
      on a.patnt_encntr_key = e.patnt_encntr_key
	  left join xref.visit_detail_mapping f
	  on a.patnt_encntr_key = f.patnt_encntr_key
      where ENCOUNTER_EFFECTIVE_DATE is not null
      and b.active_ind = 'Y'

      union
      select person_id = b.person_id
            ,observation_concept_id = isnull(d.target_concept_id, 0)
            ,observation_date = cast(a.ENCOUNTER_EFFECTIVE_DATE as date)
            ,observation_datetime = a.ENCOUNTER_EFFECTIVE_DATE
            ,observation_type_concept_id = 32817
            ,value_as_number = NULL
            ,value_as_string = a.vent_non_invasive
            ,value_as_concept_id = NULL
            ,qualifier_concept_id = NULL
            ,unit_concept_id = NULL
            ,provider_id = c.provider_id
            ,visit_occurrence_id = isnull(f.visit_occurrence_id,e.visit_occurrence_id)
            ,visit_detail_id = f.visit_detail_id
            ,observation_source_value = d.source_code
            ,observation_source_concept_id = isnull(d.source_concept_id, 0)
            ,unit_source_value = NULL
            ,qualifier_source_value = NULL
            ,source_table = 'observation_vent'
      from stage.observation_vent a 
      join xref.person_mapping b
      on a.patient_key = b.patient_key
      left join xref.provider_mapping c 
      on c.providr_key = isnull(a.Attending_Provider, a.Visit_Provider) and c.providr_key > 0
      left join xref.source_to_concept_map d 
      on d.source_code = 'Mechanical vent use - non-invasive' and d.source_vocabulary_id = 'observation'
      left join xref.visit_occurrence_mapping e
      on a.patnt_encntr_key = e.patnt_encntr_key
	  left join xref.visit_detail_mapping f
	  on a.patnt_encntr_key = f.patnt_encntr_key
      where ENCOUNTER_EFFECTIVE_DATE is not null
      and b.active_ind = 'Y'
) x
