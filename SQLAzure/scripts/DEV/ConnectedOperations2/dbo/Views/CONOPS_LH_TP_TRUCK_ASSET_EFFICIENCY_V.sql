CREATE VIEW [dbo].[CONOPS_LH_TP_TRUCK_ASSET_EFFICIENCY_V] AS


CREATE VIEW [dbo].[CONOPS_LH_TP_TRUCK_ASSET_EFFICIENCY_V]
AS

SELECT [shiftflag],
	   [siteflag],
	   [Hos],
	   [Hr],
	   AVG(AE) [AE],
	   AVG([Avail]) [Avail],
	   AVG([UofA]) [UofA]
FROM [mor].[CONOPS_MOR_HOURLY_TRUCK_ASSET_EFFICIENCY_V] WITH (NOLOCK)
WHERE [EqmtUnit] = 1
      AND [siteflag] = 'MOR'
GROUP BY [shiftflag], [siteflag], [Hos], [Hr]

UNION ALL

SELECT [shiftflag],
	   [siteflag],
	   [Hos],
	   [Hr],
	   AVG(AE) [AE],
	   AVG([Avail]) [Avail],
	   AVG([UofA]) [UofA]
FROM [bag].[CONOPS_BAG_HOURLY_TRUCK_ASSET_EFFICIENCY_V] WITH (NOLOCK)
WHERE [EqmtUnit] = 1
      AND [siteflag] = 'BAG'
GROUP BY [shiftflag], [siteflag], [Hos], [Hr]


