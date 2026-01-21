CREATE VIEW [bag].[ZZZ_CONOPS_BAG_OPERATOR_TRUCK_V_NEW] AS



-- SELECT * FROM [bag].[CONOPS_BAG_OPERATOR_TRUCK_V_NEW] WITH (NOLOCK) WHERE [shiftflag] = 'CURR'
CREATE VIEW [bag].[CONOPS_BAG_OPERATOR_TRUCK_V_NEW] 
AS

WITH CTE AS (
SELECT 
a.shiftflag,
a.siteflag,
a.truckid,
SUM(NrofDumps) AS NrofDumps
FROM [bag].[CONOPS_BAG_TRUCK_DETAIL_V] a
LEFT JOIN [bag].[CONOPS_BAG_SHIFT_OVERVIEW_V] b
ON a.shiftid = b.shiftid 
AND a.AssignedShovel = b.ShovelId
GROUP BY a.shiftflag,a.siteflag,a.truckid)


	SELECT
		[t].[shiftflag]
		,[t].[siteflag]
		,[t].[shiftid]
		,[t].ShiftIndex
		,[t].[TruckID]
		,[t].[Operator]
		,[t].[OperatorImageURL]
		,[t].[CrewName]
		,[t].[Location]
		,[t].[StatusName]
		,[t].[OperatorStatus]
		,[ShiftStartDateTime]
		,[ShiftEndDateTime]
		,Payload
		,PayloadTarget
		,DeltaC
		,DeltaCTarget
		,Loading
		,LoadingTarget
		,Spotting
		,SpottingTarget
		,IdleTime
		,IdleTimeTarget
		,EmptyTravel
		,EmptyTravelTarget
		,LoadedTravel
		,LoadedTravelTarget
		,Dumping
		,DumpingTarget
		,DumpsAtCrusher
		,DumpsAtCrusherTarget
		,DumpsAtStockpile
		,DumpsAtStockpileTarget
		,TotalMaterialDelivered
		,ISNULL(TotalMaterialDeliveredTarget,0) AS TotalMaterialDeliveredTarget
		,NrofDumps
		,0 NrofDumpsTarget
		,EFH
		,EFHTarget
		,AvgUseOfAvailibility
		,AvgUseOfAvailibilityTarget
		,0 ScoreCard --Need to Add
		,0 ScoreCardTarget --Nedd to Add
	FROM [bag].[CONOPS_BAG_OPERATOR_TRUCK_LIST_V] [t]
	LEFT JOIN [bag].[CONOPS_BAG_SHIFT_INFO_V] [shift]
	ON [t].[shiftflag] = [shift].[shiftflag]
	LEFT JOIN [bag].[CONOPS_BAG_TRUCK_POPUP_V] [pop]
	ON [pop].shiftflag = [t].shiftflag
	AND [pop].TruckID = [t].truckid
	LEFT JOIN CTE [d]
	ON [t].shiftflag = [d].shiftflag 
	AND [t].truckid = [d].truckid

