CREATE VIEW [CER].[CONOPS_CER_SP_SHOVEL_ASSET_EFFICIENCY_V] AS


--select * from [dbo].[CONOPS_LH_SP_DELAY_V] where shiftflag = 'prev'
CREATE VIEW [cer].[CONOPS_CER_SP_SHOVEL_ASSET_EFFICIENCY_V] 
AS

SELECT a.[shiftflag],
	   a.[siteflag],
	   equipment,
	   EQMTTYPE,
	   StatusName,
	   [Hos],
	   [Hr],
	   AVG(AE) [AE],
	   AVG([Avail]) [Avail],
	   AVG([UofA]) [UofA]
FROM [cer].[CONOPS_CER_HOURLY_TRUCK_ASSET_EFFICIENCY_V] a
LEFT JOIN [cer].[CONOPS_CER_SHOVEL_INFO_V] b
ON a.shiftflag = b.shiftflag AND a.Equipment = b.ShovelID
WHERE [EqmtUnit] = 2
GROUP BY a.[shiftflag], a.[siteflag], [Hos], [Hr], equipment,EQMTTYPE,StatusName



