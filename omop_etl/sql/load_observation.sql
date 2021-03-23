insert into @Schema.observation with (tablock) (
    @TableId
    [person_id]
    ,[observation_concept_id]
    ,[observation_date]
    ,[observation_datetime]
    ,[observation_type_concept_id]
    ,[value_as_number]
    ,[value_as_string]
    ,[value_as_concept_id]
    ,[qualifier_concept_id]
    ,[unit_concept_id]
    ,[provider_id]
    ,[visit_occurrence_id]
    ,[visit_detail_id]
    ,[observation_source_value]
    ,[observation_source_concept_id]
    ,[unit_source_value]
    ,[qualifier_source_value]
)
select @TableId
      a.person_id
      ,[observation_concept_id]
      ,[observation_date] = dateadd(day, @DateShift, a.observation_date)
      ,[observation_datetime] = dateadd(day, @DateShift, a.observation_datetime)
      ,[observation_type_concept_id]
      ,[value_as_number]
      ,[value_as_string]
      ,[value_as_concept_id]
      ,[qualifier_concept_id]
      ,[unit_concept_id]
      ,[provider_id]
      ,[visit_occurrence_id]
      ,[visit_detail_id]
      ,[observation_source_value]
      ,[observation_source_concept_id]
      ,[unit_source_value]
      ,[qualifier_source_value]
from @FromSchema.observation a 
join xref.person_mapping b 
on a.person_id = b.person_id 
where b.active_ind = 'Y'
