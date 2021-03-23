insert into @Schema.condition_occurrence with (tablock) (
      @TableId
       [person_id]
      ,[condition_concept_id]
      ,[condition_start_date]
      ,[condition_start_datetime]
      ,[condition_end_date]
      ,[condition_end_datetime]
      ,[condition_type_concept_id]
      ,[stop_reason]
      ,[provider_id]
      ,[visit_occurrence_id]
      ,[visit_detail_id]
      ,[condition_source_value]
      ,[condition_source_concept_id]
      ,[condition_status_source_value]
      ,[condition_status_concept_id]
)
select @TableId 
      a.person_id
      ,[condition_concept_id]
      ,condition_start_date = dateadd(day, @DateShift, a.condition_start_date)
      ,condition_start_datetime = dateadd(day, @DateShift, a.condition_start_datetime)
      ,condition_end_date = dateadd(day, @DateShift, a.condition_end_date)
      ,condition_end_datetime = dateadd(day, @DateShift, a.condition_end_datetime)
      ,[condition_type_concept_id]
      ,[stop_reason]
      ,[provider_id]
      ,[visit_occurrence_id]
      ,[visit_detail_id]
      ,[condition_source_value]
      ,[condition_source_concept_id]
      ,[condition_status_source_value]
      ,[condition_status_concept_id]
from [@FromSchema].[condition_occurrence] a
join xref.person_mapping b 
on a.person_id = b.person_id 
where b.active_ind = 'Y'
