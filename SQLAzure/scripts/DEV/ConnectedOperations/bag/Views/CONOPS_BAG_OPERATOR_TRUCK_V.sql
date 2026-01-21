CREATE VIEW [bag].[CONOPS_BAG_OPERATOR_TRUCK_V] AS



-- SELECT * FROM [bag].[CONOPS_BAG_OPERATOR_TRUCK_V] WITH (NOLOCK) WHERE [shiftflag] = 'CURR'
CREATE VIEW [bag].[CONOPS_BAG_OPERATOR_TRUCK_V] 
AS


WITH CTE AS (
SELECT
a.shiftflag,
c.truckid,
c.TotalMaterialMoved,
NULL AS TotalMaterialMovedTarget
FROM [BAG].[CONOPS_BAG_SHIFT_INFO_V] a
LEFT JOIN [BAG].[CONOPS_BAG_TRUCK_SHIFT_OVERVIEW_V] c
ON a.shiftid = c.shiftid
),

OperatorDetail AS(
SELECT 
[shift].[shiftflag]
,[shift].[shiftindex]
,[shift].[siteflag]
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
,[tp].[TPRH]
,TotalMaterialMoved
,TotalMaterialMovedTarget
,SUM(CASE WHEN [ld].DUMP_HOS = 1 THEN [ld].REPORT_PAYLOAD_SHORT_TONS ELSE 0 END ) AS FirstHourTons
,SUM(CASE WHEN [ld].DUMP_HOS = CAST(([shift].SHIFTDURATION / 3600.00 + 1) AS INT) THEN [ld].REPORT_PAYLOAD_SHORT_TONS ELSE 0 END ) AS LastHourTons
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
,[tp].TPRH
)

SELECT tl.*,
[rh].ReadyHours AS OperatorReadyHours
FROM OperatorDetail tl
LEFT JOIN [BAG].[CONOPS_BAG_OPERATOR_EQMT_READY_HOURS_V] [rh]
	ON [tl].SHIFTINDEX = [rh].SHIFTINDEX
	AND [tl].OperatorId = [rh].OperatorId
	AND [tl].TruckId = [rh].EQMT




