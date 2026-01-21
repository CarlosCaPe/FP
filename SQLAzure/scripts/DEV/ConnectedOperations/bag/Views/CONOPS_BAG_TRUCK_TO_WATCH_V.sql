CREATE VIEW [bag].[CONOPS_BAG_TRUCK_TO_WATCH_V] AS

-- SELECT * FROM [bag].[CONOPS_BAG_TRUCK_TO_WATCH_V] WITH (NOLOCK) WHERE [TruckID] = 'T501'
CREATE VIEW [bag].[CONOPS_BAG_TRUCK_TO_WATCH_V]
AS

SELECT [t].shiftflag,
	   [t].siteflag,
	   [t].TruckID,
	   [t].OperatorId,
	   [t].Location,
	   [t].StatusName,
	   [t].ShiftDuration,
	   [ae].availability_pct,
	   [tp].[TPRH],
	   [tm].TotalMaterialMined,
	   [tm].TotalMaterialMoved,
	   0 AS TotalMaterialMinedTarget
FROM [bag].[CONOPS_BAG_TRUCK_DETAIL_V] [t] WITH (NOLOCK)
LEFT JOIN [bag].[CONOPS_BAG_TP_TONS_HAUL_V] [tp]
ON [t].shiftflag = [tp].shiftflag AND [t].TruckID = [tp].[Truck]
LEFT JOIN [bag].[CONOPS_BAG_TRUCK_ASSET_EFFICIENCY_PER_TRUCK_V] [ae] WITH(NOLOCK)
ON [t].shiftid = [ae].shiftid  AND [t].TruckID = [ae].eqmt
LEFT JOIN [bag].[CONOPS_BAG_TRUCK_SHIFT_OVERVIEW_V] [tm]
ON [t].shiftid = [tm].shiftid AND [t].TruckID = [tm].TruckID



