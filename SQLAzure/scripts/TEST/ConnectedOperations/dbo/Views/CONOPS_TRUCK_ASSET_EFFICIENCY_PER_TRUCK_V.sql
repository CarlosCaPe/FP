CREATE VIEW [dbo].[CONOPS_TRUCK_ASSET_EFFICIENCY_PER_TRUCK_V] AS






--select * from [dbo].[CONOPS_TRUCK_ASSET_EFFICIENCY_PER_TRUCK_V] WITH (NOLOCK)
CREATE VIEW [dbo].[CONOPS_TRUCK_ASSET_EFFICIENCY_PER_TRUCK_V]
AS

select shiftflag, [siteflag]
, eqmt
, FORMAT(ROUND(ISNULL(availability_pct, 0), 2), '##0.##') [availability]
, CASE WHEN availability_pct IS NULL OR availability_pct = 0
   	   THEN FORMAT(0, '##0.##')
	   ELSE FORMAT(ROUND((ISNULL(Ops_efficient_pct, 0) / availability_pct * 100), 2), '##0.##')
  END [use_of_availability]
, FORMAT(ROUND(ISNULL(Ops_efficient_pct, 0), 0), '#0') [overall_efficiency]
from [mor].[CONOPS_MOR_TRUCK_ASSET_EFFICIENCY_PER_TRUCK_V] WITH (NOLOCK)
WHERE [siteflag] = 'MOR'

UNION ALL

select shiftflag, [siteflag]
, eqmt
, FORMAT(ROUND(ISNULL(availability_pct, 0), 2), '##0.##') [availability]
, CASE WHEN availability_pct IS NULL OR availability_pct = 0
   	   THEN FORMAT(0, '##0.##')
	   ELSE FORMAT(ROUND((ISNULL(Ops_efficient_pct, 0) / availability_pct * 100), 2), '##0.##')
  END [use_of_availability]
, FORMAT(ROUND(ISNULL(Ops_efficient_pct, 0), 0), '#0') [overall_efficiency]
from [bag].[CONOPS_BAG_TRUCK_ASSET_EFFICIENCY_PER_TRUCK_V] WITH (NOLOCK)
WHERE [siteflag] = 'BAG'

UNION ALL

select shiftflag, [siteflag]
, eqmt
, FORMAT(ROUND(ISNULL(availability_pct, 0), 2), '##0.##') [availability]
, CASE WHEN availability_pct IS NULL OR availability_pct = 0
   	   THEN FORMAT(0, '##0.##')
	   ELSE FORMAT(ROUND((ISNULL(Ops_efficient_pct, 0) / availability_pct * 100), 2), '##0.##')
  END [use_of_availability]
, FORMAT(ROUND(ISNULL(Ops_efficient_pct, 0), 0), '#0') [overall_efficiency]
from [saf].[CONOPS_SAF_TRUCK_ASSET_EFFICIENCY_PER_TRUCK_V] WITH (NOLOCK)
WHERE [siteflag] = 'SAF'

UNION ALL

select shiftflag, [siteflag]
, eqmt
, FORMAT(ROUND(ISNULL(availability_pct, 0), 2), '##0.##') [availability]
, CASE WHEN availability_pct IS NULL OR availability_pct = 0
   	   THEN FORMAT(0, '##0.##')
	   ELSE FORMAT(ROUND((ISNULL(Ops_efficient_pct, 0) / availability_pct * 100), 2), '##0.##')
  END [use_of_availability]
, FORMAT(ROUND(ISNULL(Ops_efficient_pct, 0), 0), '#0') [overall_efficiency]
from [sie].[CONOPS_SIE_TRUCK_ASSET_EFFICIENCY_PER_TRUCK_V] WITH (NOLOCK)
WHERE [siteflag] = 'SIE'


UNION ALL

SELECT shiftflag, [siteflag]
	, eqmt
	, FORMAT(ROUND(ISNULL(availability_pct, 0), 2), '##0.##') [availability]
	, CASE WHEN availability_pct IS NULL OR availability_pct = 0
   		   THEN FORMAT(0, '##0.##')
		   ELSE FORMAT(ROUND((ISNULL(Ops_efficient_pct, 0) / availability_pct * 100), 2), '##0.##')
	  END [use_of_availability]
	, FORMAT(ROUND(ISNULL(Ops_efficient_pct, 0), 0), '#0') [overall_efficiency]
FROM [cer].[CONOPS_CER_TRUCK_ASSET_EFFICIENCY_PER_TRUCK_V] WITH (NOLOCK)
WHERE [siteflag] = 'CER'


UNION ALL

SELECT shiftflag, [siteflag]
	, eqmt
	, FORMAT(ROUND(ISNULL(availability_pct, 0), 2), '##0.##') [availability]
	, CASE WHEN availability_pct IS NULL OR availability_pct = 0
   		   THEN FORMAT(0, '##0.##')
		   ELSE FORMAT(ROUND((ISNULL(Ops_efficient_pct, 0) / availability_pct * 100), 2), '##0.##')
	  END [use_of_availability]
	, FORMAT(ROUND(ISNULL(Ops_efficient_pct, 0), 0), '#0') [overall_efficiency]
FROM [cli].[CONOPS_CLI_TRUCK_ASSET_EFFICIENCY_PER_TRUCK_V] WITH (NOLOCK)
WHERE [siteflag] = 'CMX'

UNION ALL

SELECT shiftflag, [siteflag]
	, eqmt
	, FORMAT(ROUND(ISNULL(availability_pct, 0), 2), '##0.##') [availability]
	, CASE WHEN availability_pct IS NULL OR availability_pct = 0
   		   THEN FORMAT(0, '##0.##')
		   ELSE FORMAT(ROUND((ISNULL(Ops_efficient_pct, 0) / availability_pct * 100), 2), '##0.##')
	  END [use_of_availability]
	, FORMAT(ROUND(ISNULL(Ops_efficient_pct, 0), 0), '#0') [overall_efficiency]
FROM [chi].[CONOPS_CHI_TRUCK_ASSET_EFFICIENCY_PER_TRUCK_V] WITH (NOLOCK)
WHERE [siteflag] = 'CHI'

