truncate table preload.naaccr_data_points

insert into preload.naaccr_data_points with (tablock)
select person_id
	  ,record_id
	  ,naaccr_item_number
	  ,naaccr_item_value
	  ,histology
	  ,site
	  ,histology_site
from (
	select b.person_id
		  ,patnt_key as record_id
		  ,SUBSTRING([Histological Type], 1,4) + '/' + SUBSTRING([Histological Type], 5,1) + '-' + SUBSTRING([Topography Code],1,3) + '.' + SUBSTRING([Topography Code],4,1) AS histology_site
		  ,[Histological Type] as histology
		  ,[Topography Code] as site
		  ,[Date of diagnosis] as [390]
		  ,LATERALITY as [410]
		  ,[Grade] as [440]
		  --,[Histological Type Description] as [523]
		  ,[Chemo code summary] as [700]
		  ,[Hormone code] as [710]
		  ,[Immunotherapy code] as [720]
		  --,[Other Rx Code] as [730]
		  ,[Tumor Size Summary] as [756]
		  ,[Cs Summary Stage 2000] as [759]
		  ,[Cs Summary Stage 1977] as [760]
		  ,[Tumor Size Summary] as [780]
		  ,[Nodes Positive] as [820]
		  ,[Nodes Examined] as [830]
		  ,[Path T of TNM Stage] as [880]
		  ,[Path N of TNM Stage] as [890]
		  ,[Path M of TNM Stage] as [900]
		  ,[Clinical T of TNM Stage] as [940]
		  ,[Clinical N of TNM Stage] as [950]
		  ,[Clinical M of TNM Stage] as [960]
		  ,[Clinical AJCC Stage Group] as [970]
		  ,[Tnm Edition Number] as [1060]
		  ,[Most Definitive Surgery Date] as [1200]
		  ,[Chemo Start Date Summary] as [1220]
		  ,[Hormone Start Date] as [1230]
		  ,[Immuno Start Date] as [1240]
		  --,[Other Rx Start Date] as [1250]
		  ,[Combined Last Status] as [1760]
		  ,[First Recurrence Date] as [1860]
		  ,[First Recurrence Type] as [1880]
		  ,[Cause of Death] as [1910]
		  ,[Cs Stage Grp Display] as [3000]
		  --,[Radiation End Date] as [3220]
		  ,[Date Systemic Therapy Started] as [3230]
		  ,[Hematologic Transplant and Endocrine Procedure Sum] as [3250]
		  ,[Cs Stage Group Display - 7th Edition] as [3430]
	from dws_prod.dbo.tumor_registry_gnv_jax_all_naaccr a
	join xref.person_mapping b
	on a.patnt_key = b.patient_key and b.active_ind = 'Y'
	--take only records with 4 digit histology code + 1 digit site code.
	where len([Histological Type]) = 5
) x
cross apply (
	values 
		(390, [390]),
		(410, [410]),
		(440, [440]),
		--(523, [523]),
		(700, [700]),
		(710, [710]),
		(720, [720]),
		--(730, [730]),
		--(756, [756]),
		(759, [759]),
		(760, [760]),
		(780, [780]),
		(820, [820]),
		(830, [830]),
		(880, [880]),
		(890, [890]),
		(900, [900]),
		(940, [940]),
		(950, [950]),
		(960, [960]),
		(970, [970]),
		(1060, [1060]),
		(1200, [1200]),
		(1220, [1220]),
		(1230, [1230]),
		(1240, [1240]),
		(1760, [1760]),
		(1860, [1860]),
		(1880, [1880]),
		(1910, [1910]),
		(3000, [3000]),
		(3230, [3230]),
		(3250, [3250]),
		(3430, [3430]) 
) v (naaccr_item_number,naaccr_item_value)

