CREATE VIEW [CHI].[CONOPS_CHI_SP_SHOVEL_ASSET_EFFICIENCY_V] AS


--select * from [dbo].[CONOPS_LH_SP_DELAY_V] where shiftflag = 'prev'
CREATE VIEW [chi].[CONOPS_CHI_SP_SHOVEL_ASSET_EFFICIENCY_V] 
AS

SELECT a.[shiftflag],
	   a.[siteflag],
	   equipment,
	   eqmttype,
	   StatusName,
	   [Hos],
	   [Hr],
	   AVG(AE) [AE],
	   AVG([Avail]) [Avail],
	   AVG([UofA]) [UofA]
FROM [chi].[CONOPS_CHI_HOURLY_TRUCK_ASSET_EFFICIENCY_V] a
LEFT JOIN [chi].[CONOPS_CHI_SHOVEL_INFO_V] b
ON a.shiftflag = b.shiftflag AND a.Equipment = b.ShovelID
WHERE [EqmtUnit] = 2
GROUP BY a.[shiftflag], a.[siteflag], [Hos], [Hr], equipment,eqmttype,StatusName


