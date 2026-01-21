CREATE VIEW [ABR].[CONOPS_ABR_TP_TRUCK_ASSET_EFFICIENCY_V] AS





--select * from [abr].[CONOPS_ABR_TP_TRUCK_ASSET_EFFICIENCY_V] 
CREATE VIEW [ABR].[CONOPS_ABR_TP_TRUCK_ASSET_EFFICIENCY_V] 
AS

SELECT a.[shiftflag],
	   a.[siteflag],
	   Equipment,
	   eqmttype,
	   StatusName,
	   [Hos],
	   [Hr],
	   AVG(AE) [AE],
	   AVG([Avail]) [Avail],
	   AVG([UofA]) [UofA]
FROM [abr].[CONOPS_ABR_HOURLY_TRUCK_ASSET_EFFICIENCY_V] a
LEFT JOIN [abr].CONOPS_ABR_TRUCK_POPUP b WITH (NOLOCK)
ON a.shiftflag = b.shiftflag AND a.Equipment = b.TruckID
WHERE [EqmtUnit] = 1
GROUP BY a.[shiftflag], a.[siteflag], [Hos], [Hr], Equipment,eqmttype,StatusName



