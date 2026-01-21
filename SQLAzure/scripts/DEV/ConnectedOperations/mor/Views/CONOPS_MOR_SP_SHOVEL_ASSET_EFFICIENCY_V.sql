CREATE VIEW [mor].[CONOPS_MOR_SP_SHOVEL_ASSET_EFFICIENCY_V] AS


--select * from [dbo].[CONOPS_LH_SP_SHOVEL_ASSET_EFFICIENCY_V] WITH (NOLOCK)
CREATE VIEW [mor].[CONOPS_MOR_SP_SHOVEL_ASSET_EFFICIENCY_V]
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
FROM [mor].[CONOPS_MOR_HOURLY_TRUCK_ASSET_EFFICIENCY_V] a
LEFT JOIN [mor].[CONOPS_MOR_SHOVEL_INFO_V] b
ON a.shiftflag = b.shiftflag AND a.Equipment = b.ShovelID
WHERE [EqmtUnit] = 2
AND a.equipment NOT LIKE 'L%'
GROUP BY a.[shiftflag], a.[siteflag], [Hos], [Hr],equipment,eqmttype,statusname




