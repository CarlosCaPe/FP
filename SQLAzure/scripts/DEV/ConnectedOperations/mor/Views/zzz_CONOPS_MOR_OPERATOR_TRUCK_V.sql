CREATE VIEW [mor].[zzz_CONOPS_MOR_OPERATOR_TRUCK_V] AS







-- SELECT * FROM [mor].[CONOPS_MOR_OPERATOR_TRUCK_V] WITH (NOLOCK) WHERE [shiftflag] = 'CURR'
CREATE VIEW [mor].[zzz_CONOPS_MOR_OPERATOR_TRUCK_V] 
AS

WITH CTE AS (
	SELECT [td].ShiftFlag
		,[td].Siteflag
		,[td].TruckId
		,SUM(NrOfDumps) AS NrofDumps
	FROM [mor].[CONOPS_MOR_TRUCK_DETAIL_V] [td]
	LEFT JOIN [mor].[CONOPS_MOR_SHIFT_OVERVIEW_V] [so]
		ON [td].ShiftId = [so].ShiftId 
		AND [td].AssignedShovel = [so].ShovelId
	GROUP BY [td].ShiftFlag, [td].Siteflag, [td].TruckId
)

SELECT [tl].[shiftflag]
	,[tl].[siteflag]
	,[tl].[shiftid]
	,[tl].ShiftIndex
	,[tl].[TruckID]
	,[tl].[Operator]
	,[tl].[OperatorId]
	,ISNULL([ocw].NrOfDays, 0) as NrOfDays
	,[tl].[OperatorImageURL]
	,[tl].[CrewName] AS Crew
	,[tl].[Location]
	,[tl].[Region]
	,[tl].[StatusName] AS EqmtStatus
	,[tl].[OperatorStatus]
	,[ShiftStartDateTime]
	,[ShiftEndDateTime]
	,Payload AS AvgPayload
	,PayloadTarget AS AvgPayloadTarget
	,DeltaC
	,DeltaCTarget
	,Loading
	,LoadingTarget
	,Spotting
	,SpottingTarget
	,IdleTime AS Idle
	,IdleTimeTarget AS IdleTarget
	,EmptyTravel 
	,EmptyTravelTarget
	,LoadedTravel
	,LoadedTravelTarget
	,Dumping
	,DumpingTarget
	,DumpsAtCrusher AS DumpingToCrusher
	,DumpsAtCrusherTarget AS DumpingToCrusherTarget
	,DumpsAtStockpile AS DumpingToStockpile
	,DumpsAtStockpileTarget AS DumpingToStockpileTarget
	,TotalMaterialDelivered AS MaterialDelivered
	,ISNULL(TotalMaterialDeliveredTarget, 0) AS MaterialDeliveredTarget
	,NrofDumps AS NrDumps
	,0 AS NrDumpsTarget
	,EFH
	,EFHTarget
	,ISNULL(AvgUseOfAvailibility, 0) AS AvgUseOfAvailibility
	,AvgUseOfAvailibilityTarget
	,ISNULL([ht].Total_Score, 0) AS ScoreCard
	,0 ScoreCardTarget --Nedd to Add
FROM [mor].[CONOPS_MOR_OPERATOR_TRUCK_LIST_V] [tl]
	LEFT JOIN [mor].[CONOPS_MOR_SHIFT_INFO_V] [shift]
	ON [tl].[shiftflag] = [shift].[shiftflag]
LEFT JOIN [mor].[CONOPS_MOR_TRUCK_POPUP_V] [pop]
	ON [pop].shiftflag = [tl].shiftflag
	AND [pop].TruckID = [tl].truckid
LEFT JOIN CTE [d]
	ON [tl].shiftflag = [d].shiftflag 
	AND [tl].truckid = [d].truckid
LEFT JOIN [dbo].htos [ht] WITH (NOLOCK)
	ON [tl].SiteFlag = [ht].site_code
	AND RIGHT('0000000000' + [tl].[OperatorId], 10) = [ht].Operator_Id
	AND [tl].ShiftIndex = [ht].ShiftIndex
LEFT JOIN [dbo].[OPERATOR_CONSECUTIVE_WORKDAYS] [ocw] WITH (NOLOCK)
	ON [tl].ShiftIndex = [ocw].LastShiftIndex
	AND RIGHT('0000000000' + [tl].[OperatorId], 10) = [ocw].OperId
	AND [tl].SiteFlag = [ocw].Site_Code

