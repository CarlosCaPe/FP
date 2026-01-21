CREATE VIEW [cer].[CONOPS_CER_TRUCK_TO_WATCH_V] AS




-- SELECT * FROM [cer].[CONOPS_CER_TRUCK_TO_WATCH_V] WITH (NOLOCK) WHERE [TruckID] = 'T501'
CREATE VIEW [cer].[CONOPS_CER_TRUCK_TO_WATCH_V]
AS

SELECT [t].shiftflag,
	   [t].siteflag,
	   [t].TruckID,
	   [t].Location,
	   [t].StatusName,
	   CASE WHEN ([t].ShiftDuration/3600.00) = 0 OR [ae].availability_pct IS NULL OR [ae].availability_pct = 0  THEN 0
			ELSE COALESCE([tp].tonsHaul, 0) / (([t].ShiftDuration/3600.00) * ([ae].availability_pct/100))
	   END [TPRH],
	   [tm].TotalMaterialMined,
	   [tm].TotalMaterialMoved,
	   0 AS TotalMaterialMinedTarget
FROM [cer].[CONOPS_CER_TRUCK_DETAIL_V] [t] WITH (NOLOCK)
LEFT JOIN [cer].[CONOPS_CER_TRUCK_TPRH] [tp] WITH(NOLOCK)
ON [t].shiftid = [tp].shiftid AND [t].TruckID = [tp].[Truck]
LEFT JOIN [cer].[CONOPS_CER_TRUCK_ASSET_EFFICIENCY_PER_TRUCK_V] [ae] WITH(NOLOCK)
ON [tp].shiftid = [ae].shiftid  AND [tp].Truck = [ae].eqmt
LEFT JOIN [cer].[CONOPS_CER_TRUCK_SHIFT_OVERVIEW_V] [tm]
ON [t].shiftid = [tm].shiftid AND [t].TruckID = [tm].TruckID


