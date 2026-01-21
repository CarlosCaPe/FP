CREATE VIEW [dbo].[CONOPS_TRUCK_ASSET_EFFICIENCY_PER_TRUCK_V] AS


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


