CREATE VIEW [MOR].[CONOPS_MOR_OPERATOR_TRUCK_DETAIL_DELTA_C_V] AS

--SELECT * FROM [mor].[CONOPS_MOR_OPERATOR_TRUCK_DETAIL_DELTA_C_V] WITH (NOLOCK) WHERE shiftflag = 'PREV'
CREATE VIEW [mor].[CONOPS_MOR_OPERATOR_TRUCK_DETAIL_DELTA_C_V]
AS

WITH CTE AS (
SELECT
    a.shiftflag,
    a.truckid,
    SUM(c.TotalMineralsMined) TotalMaterialMoved,
    NULL AS TotalMaterialMovedTarget
FROM [mor].[CONOPS_MOR_TRUCK_DETAIL_V] a
LEFT JOIN [mor].[CONOPS_MOR_TRUCK_SHIFT_OVERVIEW_V] c
    ON a.shiftid = c.shiftid
    AND a.TruckId = c.TruckId
GROUP BY a.shiftflag,a.truckid
)    
    
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
    CASE WHEN ([shift].ShiftDuration/3600.00) = 0 OR [Availability] IS NULL OR [Availability] = 0 THEN 0    
    ELSE COALESCE([tp].tonsHaul, 0) / (([shift].ShiftDuration/3600.00) * ([Availability]/100)) END AS TPRH,    
    NULL TPRHTarget,    
    TotalMaterialMoved,    
    TotalMaterialMovedTarget,    
    ISNULL(AvgUseOfAvailibility, 0) AS AvgUseOfAvailibility,    
    AvgUseOfAvailibilityTarget,    
    SUM(CASE WHEN DUMPTIME_HOS = 0 THEN [ld].FieldLSizeTons ELSE 0 END ) AS FirstHourTons,    
    SUM(CASE WHEN DUMPTIME_HOS = 11 THEN [ld].FieldLSizeTons ELSE 0 END ) AS LastHourTons    
FROM [mor].[CONOPS_MOR_SHIFT_INFO_V] [shift]    
LEFT JOIN [mor].[CONOPS_MOR_OPERATOR_TRUCK_LIST_V] [tl]    
    ON [shift].shiftflag = [tl].shiftflag    
LEFT JOIN [mor].[CONOPS_MOR_TRUCK_POPUP] [pop] WITH (NOLOCK)
    ON [pop].shiftflag = [tl].shiftflag    
    AND [pop].TruckID = [tl].truckid    
LEFT JOIN [mor].[CONOPS_MOR_TRUCK_TPRH] [tp]    
    ON [shift].shiftid = [tp].shiftid     
    AND [tl].TruckID = [tp].[Truck]    
LEFT JOIN CTE [tm]    
    ON [tm].shiftflag = [tl].shiftflag     
    AND [tl].TruckID = [tm].TruckID    
LEFT JOIN MOR.SHIFT_DUMP_DETAIL_V [ld] WITH (NOLOCK)
	ON [shift].ShiftId = [ld].ShiftId 
	AND [ld].Truck_OperatorId = [tl].[OperatorId] 
LEFT JOIN [dbo].htos [ht] WITH (NOLOCK)    
    ON [tl].SiteFlag = [ht].site_code    
    AND [tl].[OperatorId] = [ht].Operator_Id    
    AND [tp].ShiftId = [ht].ShiftId    
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
[tp].tonsHaul,    
TotalMaterialMoved,    
TotalMaterialMovedTarget    


