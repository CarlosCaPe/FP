CREATE VIEW [cer].[CONOPS_CER_OPERATOR_TRUCK_DETAIL_DELTA_C_V] AS




  
    
-- SELECT * FROM [cer].[CONOPS_CER_OPERATOR_TRUCK_DETAIL_DELTA_C_V] WITH (NOLOCK) WHERE shiftflag = 'CURR'      
CREATE VIEW [cer].[CONOPS_CER_OPERATOR_TRUCK_DETAIL_DELTA_C_V]       
AS      
      
    
    
WITH CTE AS (    
SELECT
a.shiftflag,
a.truckid,
SUM(c.TotalMaterialMoved) TotalMaterialMoved,
NULL AS TotalMaterialMovedTarget
FROM [CER].[CONOPS_CER_TRUCK_DETAIL_V] a
LEFT JOIN [CER].[CONOPS_CER_TRUCK_SHIFT_OVERVIEW_V] c
ON a.shiftid = c.shiftid AND a.TruckId = c.TruckId
GROUP BY a.shiftflag,a.truckid)    
    
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
SUM (CASE WHEN [ld].TimeEmpty <= 3600 THEN [ld].Dumptons ELSE 0 END ) AS FirstHourTons,    
SUM (CASE WHEN [ld].TimeEmpty > ((([shift].ShiftDuration / 3600) -1) * 3600) THEN [ld].Dumptons ELSE 0 END ) AS LastHourTons    
FROM [cer].[CONOPS_CER_SHIFT_INFO_V] [shift]    
LEFT JOIN [cer].[CONOPS_CER_OPERATOR_TRUCK_LIST_V] [tl]    
ON [shift].shiftflag = [tl].shiftflag    
LEFT JOIN [cer].[CONOPS_CER_TRUCK_POPUP] [pop] WITH (NOLOCK)
ON [pop].shiftflag = [tl].shiftflag    
AND [pop].TruckID = [tl].truckid    
LEFT JOIN [cer].[CONOPS_CER_TRUCK_TPRH] [tp]    
ON [shift].shiftid = [tp].shiftid     
AND [tl].TruckID = [tp].[Truck]    
LEFT JOIN CTE [tm]    
ON [tm].shiftflag = [tl].shiftflag     
AND [tl].TruckID = [tm].TruckID    
LEFT JOIN [dbo].[LH_DUMP] [ld] WITH (NOLOCK)    
ON [shift].shiftindex = [ld].shiftindex     
AND [ld].site_code = 'CER'    
AND [ld].Oper = [tl].[OperatorId]    
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
      
      
    
  




