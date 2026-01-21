CREATE VIEW [BAG].[CONOPS_BAG_OPERATOR_TRUCK_DETAIL_DELTA_C_V] AS

-- SELECT * FROM [bag].[CONOPS_BAG_OPERATOR_TRUCK_DETAIL_DELTA_C_V] WITH (NOLOCK) WHERE shiftflag = 'CURR'
CREATE VIEW [bag].[CONOPS_BAG_OPERATOR_TRUCK_DETAIL_DELTA_C_V] 
AS

WITH CTE AS (
SELECT
a.shiftflag,
c.truckid,
c.TotalMaterialMoved,
NULL AS TotalMaterialMovedTarget
FROM [BAG].[CONOPS_BAG_SHIFT_INFO_V] a
LEFT JOIN [BAG].[CONOPS_BAG_TRUCK_SHIFT_OVERVIEW_V] c
ON a.shiftid = c.shiftid)

SELECT
[shift].shiftflag,
[shift].siteflag,
[tl].OperatorId,
[tl].TruckId,
DeltaC,
[pop].IdleTime,
IdleTimeTarget,
Spotting,
SpottingTarget,
Loading,
LoadingTarget,
LoadedTravel,
LoadedTravelTarget,
Dumping,
DumpingTarget,
DumpsAtStockpile,
DumpsAtStockpileTarget,
DumpsAtCrusher,
DumpsAtCrusherTarget,
EmptyTravel,
EmptyTravelTarget,
[pop].EFH,
EFHTarget,
ISNULL([ht].Total_Score, 0) AS HTOS,
0 HTOSTarget,
[tp].[TPRH],
NULL TPRHTarget,
TotalMaterialMoved,
TotalMaterialMovedTarget,
ISNULL(AvgUseOfAvailibility, 0) AS AvgUseOfAvailibility,
AvgUseOfAvailibilityTarget,
SUM(CASE WHEN [ld].DUMP_HOS = 1 THEN [ld].REPORT_PAYLOAD_SHORT_TONS ELSE 0 END ) AS FirstHourTons,
SUM(CASE WHEN [ld].DUMP_HOS = CAST(([shift].SHIFTDURATION / 3600.00 + 1) AS INT) THEN [ld].REPORT_PAYLOAD_SHORT_TONS ELSE 0 END ) AS LastHourTons
FROM [bag].[CONOPS_BAG_SHIFT_INFO_V] [shift]
LEFT JOIN [bag].[CONOPS_BAG_OPERATOR_TRUCK_LIST_V] [tl]
ON [shift].shiftflag = [tl].shiftflag
LEFT JOIN [bag].[CONOPS_BAG_TRUCK_POPUP] [pop] WITH (NOLOCK)
ON [pop].shiftflag = [tl].shiftflag
AND [pop].TruckID = [tl].truckid
LEFT JOIN [BAG].[CONOPS_BAG_TP_TONS_HAUL_V] [tp]
ON [shift].shiftflag = [tp].shiftflag 
AND [tl].TruckID = [tp].[Truck]
LEFT JOIN CTE [tm]
ON [tm].shiftflag = [tl].shiftflag 
AND [tl].TruckID = [tm].TruckID
LEFT JOIN [BAG].[FLEET_TRUCK_CYCLE_V] [ld]
ON [shift].SHIFTID = [ld].SHIFT_ID 
AND [ld].TRUCK_OPERATOR_ID = [tl].[OperatorId]
LEFT JOIN [dbo].htos [ht] WITH (NOLOCK)
ON [tl].SiteFlag = [ht].site_code
AND [tl].[OperatorId] = [ht].Operator_Id
AND [shift].ShiftId = [ht].ShiftId
GROUP BY
[shift].shiftflag,
[shift].siteflag,
[tl].OperatorId,
[tl].TruckId,
DeltaC,
[pop].IdleTime,
IdleTimeTarget,
Spotting,
SpottingTarget,
Loading,
LoadingTarget,
LoadedTravel,
LoadedTravelTarget,
Dumping,
DumpingTarget,
DumpsAtStockpile,
DumpsAtStockpileTarget,
DumpsAtCrusher,
DumpsAtCrusherTarget,
EmptyTravel,
EmptyTravelTarget,
[pop].EFH,
EFHTarget,
[ht].Total_Score,
[shift].ShiftDuration,
[Availability],
AvgUseOfAvailibility,
AvgUseOfAvailibilityTarget,
[tp].TPRH,
TotalMaterialMoved,
TotalMaterialMovedTarget










