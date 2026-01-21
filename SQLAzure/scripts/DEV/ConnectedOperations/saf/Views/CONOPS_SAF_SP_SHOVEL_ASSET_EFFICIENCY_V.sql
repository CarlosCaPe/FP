CREATE VIEW [saf].[CONOPS_SAF_SP_SHOVEL_ASSET_EFFICIENCY_V] AS


--select * from [dbo].[CONOPS_LH_SP_DELAY_V] where shiftflag = 'prev'
CREATE VIEW [saf].[CONOPS_SAF_SP_SHOVEL_ASSET_EFFICIENCY_V] 
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
FROM [saf].[CONOPS_SAF_HOURLY_TRUCK_ASSET_EFFICIENCY_V] a
LEFT JOIN [saf].[CONOPS_SAF_SHOVEL_INFO_V] b
ON a.shiftflag = b.shiftflag AND a.Equipment = b.ShovelID
WHERE [EqmtUnit] = 2
GROUP BY a.[shiftflag], a.[siteflag], [Hos], [Hr], equipment,eqmttype,statusname



