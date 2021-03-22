insert into preload.observation with (tablock)
select distinct *
from (
      select person_id = b.person_id
            ,observation_concept_id = isnull(d.target_concept_id,0)
            ,observation_date = cast(a.Intubation_Dt as date)
            ,observation_datetime = a.Intubation_Dt
            ,observation_type_concept_id = 32817
            ,value_as_number = NULL
            ,value_as_string = a.Airway_Display_Name
            ,value_as_concept_id = NULL
            ,qualifier_concept_id = NULL
            ,unit_concept_id = NULL
            ,provider_id = c.provider_id
            ,visit_occurrence_id = e.visit_occurrence_id
            ,visit_detail_id = NULL
            ,observation_source_value = d.source_code
            ,observation_source_concept_id = isnull(d.source_concept_id,0)
            ,unit_source_value = NULL
            ,qualifier_source_value = NULL
            ,source_table = 'observation_lda'
      from stage.observation_lda a 
      join xref.person_mapping b
      on a.patient_key = b.patient_key
      left join xref.provider_mapping c 
      on c.providr_key = isnull(a.Attending_Provider, a.Visit_Provider)
      left join xref.source_to_concept_map d 
      on source_code = 'LDA - intubation tube type' and source_vocabulary_id = 'observation'
      left join xref.visit_occurrence_mapping e
      on a.patnt_encntr_key = e.patnt_encntr_key

      union
      select person_id = b.person_id
            ,observation_concept_id = d.target_concept_id
            ,observation_date = cast(a.Intubation_Dt as date)
            ,observation_datetime = a.Intubation_Dt
            ,observation_type_concept_id = 32817
            ,value_as_number =NULL
            ,value_as_string = 'PLACEMENT'
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
            ,source_table = 'observation_lda'
      from stage.observation_lda a 
      join xref.person_mapping b
      on a.patient_key = b.patient_key
      left join xref.provider_mapping c 
      on c.providr_key = isnull(a.Attending_Provider, a.Visit_Provider)
      left join xref.source_to_concept_map d 
      on source_code = 'LDA - intubation start and end times' and source_vocabulary_id = 'observation'
      left join xref.visit_occurrence_mapping e
      on a.patnt_encntr_key = e.patnt_encntr_key

      union
      select person_id = b.person_id
            ,observation_concept_id = d.target_concept_id
            ,observation_date = cast(a.Extubation_Dt as date)
            ,observation_datetime = a.Extubation_Dt
            ,observation_type_concept_id = 32817
            ,value_as_number =NULL
            ,value_as_string = 'REMOVAL'
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
            ,source_table = 'observation_lda'
      from stage.observation_lda a 
      join xref.person_mapping b
      on a.patient_key = b.patient_key
      left join xref.provider_mapping c 
      on c.providr_key = isnull(a.Attending_Provider, a.Visit_Provider)
      left join xref.source_to_concept_map d 
      on source_code = 'LDA - intubation start and end times' and source_vocabulary_id = 'observation'
      left join xref.visit_occurrence_mapping e
      on a.patnt_encntr_key = e.patnt_encntr_key
) x 
where x.observation_date is not NULL
