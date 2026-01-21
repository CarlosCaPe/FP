CREATE VIEW [dbo].[CONOPS_LH_SHOVEL_ASSET_EFFICIENCY_V] AS


CREATE VIEW [dbo].[CONOPS_LH_SHOVEL_ASSET_EFFICIENCY_V]
AS

SELECT [shift].shiftflag,
	   [shift].[siteflag],
	   FORMAT(ROUND(ISNULL(Ops_efficient_pct, 0), 0), '#0') [overall_efficiency],
	   FORMAT(ROUND(ISNULL(Ops_efficient_pct, 0), 2), '##0.##') [efficiency],
	   FORMAT(ROUND(ISNULL(availability_pct, 0), 2), '##0.##') [availability],
	   CASE WHEN availability_pct IS NULL OR availability_pct = 0
		    THEN FORMAT(0, '##0.##')
		    ELSE FORMAT(ROUND((ISNULL(Ops_efficient_pct, 0) / availability_pct * 100), 2), '##0.##')
	   END [use_of_availability]
FROM [dbo].[SHIFT_INFO_V] [shift] WITH (NOLOCK)
LEFT JOIN [mor].[CONOPS_MOR_SHOVEL_ASSET_EFFICIENCY_V] [ae]  WITH (NOLOCK)
ON [shift].shiftid = [ae].shiftid
WHERE [shift].[siteflag] = 'MOR'

UNION ALL

SELECT [shift].shiftflag,
	   [shift].[siteflag],
	   FORMAT(ROUND(ISNULL(Ops_efficient_pct, 0), 0), '#0') [overall_efficiency],
	   FORMAT(ROUND(ISNULL(Ops_efficient_pct, 0), 2), '##0.##') [efficiency],
	   FORMAT(ROUND(ISNULL(availability_pct, 0), 2), '##0.##') [availability],
	   CASE WHEN availability_pct IS NULL OR availability_pct = 0
		    THEN FORMAT(0, '##0.##')
		    ELSE FORMAT(ROUND((ISNULL(Ops_efficient_pct, 0) / availability_pct * 100), 2), '##0.##')
	   END [use_of_availability]
FROM [dbo].[SHIFT_INFO_V] [shift] WITH (NOLOCK)
LEFT JOIN [bag].[CONOPS_BAG_SHOVEL_ASSET_EFFICIENCY_V] [ae]  WITH (NOLOCK)
ON [shift].shiftid = [ae].shiftid
WHERE [shift].[siteflag] = 'BAG'


