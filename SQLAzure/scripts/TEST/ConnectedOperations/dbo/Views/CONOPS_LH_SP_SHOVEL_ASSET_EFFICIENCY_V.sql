CREATE VIEW [dbo].[CONOPS_LH_SP_SHOVEL_ASSET_EFFICIENCY_V] AS






--select * from [dbo].[CONOPS_LH_SP_SHOVEL_ASSET_EFFICIENCY_V] WITH (NOLOCK)
CREATE VIEW [dbo].[CONOPS_LH_SP_SHOVEL_ASSET_EFFICIENCY_V]
AS

SELECT [shiftflag],
	   [siteflag],
	   [Hos],
	   [Hr],
	   AVG(AE) [AE],
	   AVG([Avail]) [Avail],
	   AVG([UofA]) [UofA]
FROM [mor].[CONOPS_MOR_HOURLY_TRUCK_ASSET_EFFICIENCY_V] WITH (NOLOCK)
WHERE [EqmtUnit] = 2
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
WHERE [EqmtUnit] = 2
	  AND [siteflag] = 'BAG'
GROUP BY [shiftflag], [siteflag], [Hos], [Hr]

UNION ALL

SELECT [shiftflag],
	   [siteflag],
	   [Hos],
	   [Hr],
	   AVG(AE) [AE],
	   AVG([Avail]) [Avail],
	   AVG([UofA]) [UofA]
FROM [saf].[CONOPS_SAF_HOURLY_TRUCK_ASSET_EFFICIENCY_V] WITH (NOLOCK)
WHERE [EqmtUnit] = 2
	  AND [siteflag] = 'SAF'
GROUP BY [shiftflag], [siteflag], [Hos], [Hr]



UNION ALL

SELECT [shiftflag],
	   [siteflag],
	   [Hos],
	   [Hr],
	   AVG(AE) [AE],
	   AVG([Avail]) [Avail],
	   AVG([UofA]) [UofA]
FROM [sie].[CONOPS_SIE_HOURLY_TRUCK_ASSET_EFFICIENCY_V] WITH (NOLOCK)
WHERE [EqmtUnit] = 2
	  AND [siteflag] = 'SIE'
GROUP BY [shiftflag], [siteflag], [Hos], [Hr]


UNION ALL

SELECT [shiftflag],
	   [siteflag],
	   [Hos],
	   [Hr],
	   AVG(AE) [AE],
	   AVG([Avail]) [Avail],
	   AVG([UofA]) [UofA]
FROM [cer].[CONOPS_CER_HOURLY_TRUCK_ASSET_EFFICIENCY_V] WITH (NOLOCK)
WHERE [EqmtUnit] = 2
	  AND [siteflag] = 'CER'
GROUP BY [shiftflag], [siteflag], [Hos], [Hr]


UNION ALL

SELECT [shiftflag],
	   [siteflag],
	   [Hos],
	   [Hr],
	   AVG(AE) [AE],
	   AVG([Avail]) [Avail],
	   AVG([UofA]) [UofA]
FROM [cli].[CONOPS_CLI_HOURLY_TRUCK_ASSET_EFFICIENCY_V] WITH (NOLOCK)
WHERE [EqmtUnit] = 2
	  AND [siteflag] = 'CMX'
GROUP BY [shiftflag], [siteflag], [Hos], [Hr]

UNION ALL

SELECT [shiftflag],
	   [siteflag],
	   [Hos],
	   [Hr],
	   AVG(AE) [AE],
	   AVG([Avail]) [Avail],
	   AVG([UofA]) [UofA]
FROM [chi].[CONOPS_CHI_HOURLY_TRUCK_ASSET_EFFICIENCY_V] WITH (NOLOCK)
WHERE [EqmtUnit] = 2
	  AND [siteflag] = 'CHI'
GROUP BY [shiftflag], [siteflag], [Hos], [Hr]


