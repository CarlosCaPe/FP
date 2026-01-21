CREATE VIEW [sie].[CONOPS_SIE_SP_SHOVEL_ASSET_EFFICIENCY_V] AS


--select * from [dbo].[CONOPS_LH_SP_DELAY_V] where shiftflag = 'prev'
CREATE VIEW [sie].[CONOPS_SIE_SP_SHOVEL_ASSET_EFFICIENCY_V] 
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
FROM [sie].[CONOPS_SIE_HOURLY_TRUCK_ASSET_EFFICIENCY_V] a
LEFT JOIN [sie].[CONOPS_SIE_SHOVEL_INFO_V] b
ON a.shiftflag = b.shiftflag AND a.Equipment = b.ShovelID
WHERE [EqmtUnit] = 2
GROUP BY a.[shiftflag], a.[siteflag], [Hos], [Hr], equipment, eqmttype, statusname


