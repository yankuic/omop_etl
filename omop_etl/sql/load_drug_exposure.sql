drop index if exists
      [ix_drugconceptid_personid] ON [dbo].[drug_exposure],
      [ix_personid_drugconceptid] ON [dbo].[drug_exposure]

alter table [dbo].[drug_exposure] 
drop constraint if exists [pk_drug_exposure]

insert into dbo.drug_exposure with (tablock) (
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
select distinct person_id
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
from preload.drug_exposure

create nonclustered index [ix_drugconceptid_personid] 
on [dbo].[drug_exposure]
(
	[drug_concept_id] ASC,
	[person_id] ASC
) with (PAD_INDEX = OFF
       ,STATISTICS_NORECOMPUTE = OFF
       ,SORT_IN_TEMPDB = OFF
       ,DROP_EXISTING = OFF
       ,ONLINE = OFF
       ,ALLOW_ROW_LOCKS = ON
       ,ALLOW_PAGE_LOCKS = ON
       ,OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF
) ON [fg_user1]

create nonclustered index [ix_personid_drugconceptid] 
on [dbo].[drug_exposure]
(
	[person_id] ASC,
	[drug_concept_id] ASC
)with (PAD_INDEX = OFF
      ,STATISTICS_NORECOMPUTE = OFF
      ,SORT_IN_TEMPDB = OFF
      ,DROP_EXISTING = OFF
      ,ONLINE = OFF
      ,ALLOW_ROW_LOCKS = ON
      ,ALLOW_PAGE_LOCKS = ON
      ,OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF
) ON [fg_user1]

alter table [dbo].[drug_exposure] 
add constraint [pk_drug_exposure] PRIMARY KEY CLUSTERED 
(
	[drug_exposure_id] ASC,
	[person_id] ASC,
	[drug_concept_id] ASC
)with (PAD_INDEX = OFF
      ,STATISTICS_NORECOMPUTE = OFF
      ,SORT_IN_TEMPDB = OFF
      ,IGNORE_DUP_KEY = OFF
      ,ONLINE = OFF
      ,ALLOW_ROW_LOCKS = ON
      ,ALLOW_PAGE_LOCKS = ON
      ,OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF
) ON [fg_user1]
