CREATE VIEW [CHI].[CONOPS_CHI_OPERATOR_TRUCK_V] AS






  
    



-- SELECT * FROM [chi].[CONOPS_CHI_OPERATOR_TRUCK_V] WITH (NOLOCK) WHERE [shiftflag] = 'CURR'
CREATE VIEW [chi].[CONOPS_CHI_OPERATOR_TRUCK_V] 
AS


WITH CTE AS (
SELECT
a.shiftflag,
a.truckid,
SUM(c.TotalMaterialMoved) TotalMaterialMoved,
NULL AS TotalMaterialMovedTarget
FROM [CHI].[CONOPS_CHI_TRUCK_DETAIL_V] a
LEFT JOIN [CHI].[CONOPS_CHI_TRUCK_SHIFT_OVERVIEW_V] c
ON a.shiftid = c.shiftid AND a.TruckId = c.TruckId
GROUP BY a.shiftflag,a.truckid
),

OperatorDetail AS(
SELECT 
[shift].[shiftflag]
,[shift].[siteflag]
,[shift].[shiftindex]
,[tl].[TruckID]
,[tl].[Operator]
,[tl].[OperatorId]
,[tl].[OperatorImageURL]
,[tl].[CrewName] AS Crew
,[tl].[Location]
,[tl].[Region]
,[tl].[StatusName] AS EqmtStatus
,[tl].[OperatorStatus]
,[ShiftStartDateTime]
,[ShiftEndDateTime]
,[pop].DeltaC
,[pop].DeltaCTarget
,[pop].EFH
,[pop].EFHTarget
,ISNULL([pop].AvgUseOfAvailibility, 0) AS AvgUseOfAvailibility
,[pop].AvgUseOfAvailibilityTarget
,CASE WHEN ([shift].ShiftDuration/3600.00) = 0 OR (([shift].ShiftDuration/3600.00) * ([Availability]) / 100) = 0 OR [Availability] IS NULL OR [Availability] = 0 THEN 0
ELSE COALESCE([tp].tonsHaul, 0) / (([shift].ShiftDuration/3600.00) * ([Availability]/100)) END AS [TPRH]
,TotalMaterialMoved
,TotalMaterialMovedTarget
,SUM (CASE WHEN [ld].TimeEmpty <= 3600 THEN [ld].Dumptons ELSE 0 END ) AS FirstHourTons
,SUM (CASE WHEN [ld].TimeEmpty > ((([shift].ShiftDuration / 3600) -1) * 3600) THEN [ld].Dumptons ELSE 0 END ) AS LastHourTons
FROM [chi].[CONOPS_CHI_SHIFT_INFO_V] [shift]
LEFT JOIN [chi].[CONOPS_CHI_OPERATOR_TRUCK_LIST_V] [tl]
ON [shift].shiftflag = [tl].shiftflag
LEFT JOIN [chi].[CONOPS_CHI_TRUCK_POPUP] [pop] WITH (NOLOCK)
ON [pop].shiftflag = [tl].shiftflag
AND [pop].TruckID = [tl].truckid
LEFT JOIN [chi].[CONOPS_CHI_TRUCK_TPRH] [tp]
ON [shift].shiftid = [tp].shiftid 
AND [tl].TruckID = [tp].[Truck]
LEFT JOIN CTE [tm]
ON [tm].shiftflag = [tl].shiftflag 
AND [tl].TruckID = [tm].TruckID
LEFT JOIN [dbo].[LH_DUMP] [ld] WITH (NOLOCK)
ON [shift].shiftindex = [ld].shiftindex 
AND [ld].site_code = 'CHI'
AND [ld].Oper = [tl].[OperatorId]
GROUP BY
[shift].[shiftflag]
,[shift].[shiftindex]
,[shift].[siteflag]
,[tl].[TruckID]
,[tl].[Operator]
,[tl].[OperatorId]
,[tl].[OperatorImageURL]
,[tl].[CrewName]
,[tl].[Location]
,[tl].[Region]
,[tl].[StatusName]
,[tl].[OperatorStatus]
,[ShiftStartDateTime]
,[ShiftEndDateTime]
,DeltaC
,DeltaCTarget
,[pop].EFH
,[pop].EFHTarget
,AvgUseOfAvailibility
,AvgUseOfAvailibilityTarget
,TotalMaterialMoved
,TotalMaterialMovedTarget
,[shift].ShiftDuration
,[Availability]
,[tp].tonsHaul
)


SELECT tl.*,
[rh].ReadyHours AS OperatorReadyHours
FROM OperatorDetail tl
LEFT JOIN [CHI].[CONOPS_CHI_OPERATOR_EQMT_READY_HOURS_V] [rh]
	ON [tl].SHIFTINDEX = [rh].SHIFTINDEX
	AND [tl].OperatorId = [rh].OperatorId
	AND [tl].TruckId = [rh].EQMT




