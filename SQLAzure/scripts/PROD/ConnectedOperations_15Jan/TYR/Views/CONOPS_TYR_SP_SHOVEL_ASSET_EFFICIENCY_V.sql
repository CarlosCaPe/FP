CREATE VIEW [TYR].[CONOPS_TYR_SP_SHOVEL_ASSET_EFFICIENCY_V] AS





--select * from [dbo].[CONOPS_LH_SP_SHOVEL_ASSET_EFFICIENCY_V] WITH (NOLOCK)
CREATE VIEW [TYR].[CONOPS_TYR_SP_SHOVEL_ASSET_EFFICIENCY_V]
AS

SELECT a.[shiftflag],
	   a.[siteflag],
	   equipment,
	   eqmttype,
	   statusname,
	   [Hos],
	   [Hr],
	   AVG(AE) [AE],
	   AVG([Avail]) [Avail],
	   AVG([UofA]) [UofA]
FROM [tyr].[CONOPS_TYR_HOURLY_TRUCK_ASSET_EFFICIENCY_V] a
LEFT JOIN [tyr].[CONOPS_TYR_SHOVEL_INFO_V] b
ON a.shiftflag = b.shiftflag AND a.Equipment = b.ShovelID
WHERE [EqmtUnit] = 2
GROUP BY a.[shiftflag], a.[siteflag], [Hos], [Hr],equipment,eqmttype,statusname




