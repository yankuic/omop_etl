insert into @Schema.procedure_occurrence with (tablock) (
    @TableId
    [person_id]
    ,[procedure_concept_id]
    ,[procedure_date]
    ,[procedure_datetime]
    ,[procedure_type_concept_id]
    ,[modifier_concept_id]
    ,[quantity]
    ,[provider_id]
    ,[visit_occurrence_id]
    ,[visit_detail_id]
    ,[procedure_source_value]
    ,[procedure_source_concept_id]
    ,[modifier_source_value]
)
select @TableId
    a.person_id
    ,[procedure_concept_id]
    ,[procedure_date] = dateadd(day, @DateShift, a.procedure_date)
    ,[procedure_datetime] = dateadd(day, @DateShift, a.procedure_datetime)
    ,[procedure_type_concept_id]
    ,[modifier_concept_id]
    ,[quantity]
    ,[provider_id]
    ,[visit_occurrence_id]
    ,[visit_detail_id]
    ,[procedure_source_value]
    ,[procedure_source_concept_id]
    ,[modifier_source_value]
from @FromSchema.procedure_occurrence a 
join xref.person_mapping b
on a.person_id = b.person_id
where b.active_ind = 'Y'
