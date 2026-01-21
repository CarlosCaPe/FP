CREATE VIEW [TYR].[CONOPS_TYR_TRUCK_POPUP_V] AS



-- SELECT * FROM [tyr].[CONOPS_TYR_TRUCK_POPUP_V] WITH (NOLOCK) WHERE [shiftflag] = 'CURR'
CREATE VIEW [TYR].[CONOPS_TYR_TRUCK_POPUP_V] 
AS

WITH TruckTons AS (
	SELECT sd.shiftid
		,sd.siteflag
		,t.FieldId AS [TruckId]
		,SUM(sd.FieldLsizetons) AS [Tons]
	FROM [tyr].SHIFT_DUMP sd WITH (NOLOCK)
	LEFT JOIN [tyr].shift_eqmt t WITH (NOLOCK) ON t.Id = sd.FieldTruck
	GROUP BY sd.shiftid
		,t.FieldId
		,sd.siteflag
),

AE AS (
	SELECT shiftflag
		,[siteflag]
		,eqmt
		,FORMAT(availability_pct, '##0.##') AS availability
		,CASE 
			WHEN availability_pct IS NULL
				OR availability_pct = 0
				THEN FORMAT(0, '##0.##')
			ELSE FORMAT(ROUND((ISNULL(Ops_efficient_pct, 0) / availability_pct * 100), 2), '##0.##')
			END [use_of_availability]
	FROM [tyr].[CONOPS_TYR_TRUCK_ASSET_EFFICIENCY_PER_TRUCK_V] WITH (NOLOCK)
),

TruckLoad AS (
	SELECT Shiftindex
		,truck
		,avg(LoadingTarget) LoadingTarget
		,avg(EmptyTravelTarget) EmptyTravelTarget
		,avg(LoadedTravelTarget) LoadedTravelTarget
	FROM [tyr].[CONOPS_TYR_EQMT_TRUCK_LOAD_DELTAC_V]
	GROUP BY shiftindex
		,truck
)


SELECT [t].shiftflag
	,[t].siteflag
	,[t].[shiftid]
	,[t].shiftindex
	,[t].TruckID
	,[t].eqmttype
	,UPPER([t].Operator) Operator
	,[t].OperatorId
	,[t].OperatorImageURL
	,[t].StatusName
	,[t].ReasonId
	,[t].ReasonDesc
	,COALESCE([payload].AVG_Payload, 0) AS [Payload]
	,COALESCE([payload].Target, 0) [PayloadTarget]
	,COALESCE([tt].[Tons] / 1000.0, 0) [TotalMaterialDelivered]
	,NULL [TotalMaterialDeliveredTarget]
	,COALESCE(DeltaC, 0) AS DeltaC
	,[tg].DeltaCTarget
	,COALESCE(idletime, 0) AS IdleTime
	,[tg].IdleTimeTarget
	,COALESCE(spottime, 0) AS Spotting
	,[tg].SpottingTarget
	,COALESCE(loadtime, 0) AS Loading
	,COALESCE([tl].loadingtarget, 0) AS LoadingTarget
	,COALESCE(DumpingTime, 0) AS Dumping
	,[tg].DumpingTarget
	,COALESCE(EFH, 0) AS Efh
	,[tg].EfhTarget
	,COALESCE(DumpingAtStockpile, 0) AS [DumpsAtStockpile]
	,[tg].DumpingatStockpileTarget AS DumpsAtStockpileTarget
	,COALESCE(DumpingAtCrusher, 0) AS DumpsAtCrusher
	,[tg].DumpingAtCrusherTarget AS DumpsAtCrusherTarget
	,COALESCE(LoadedTravel, 0) AS LoadedTravel
	,COALESCE([tl].LoadedTravelTarget, 0) AS LoadedTravelTarget
	,COALESCE(EmptyTravel, 0) AS EmptyTravel
	,COALESCE([tl].EmptyTravelTarget, 0) AS EmptyTravelTarget
	,[ae].[use_of_availability] AS AvgUseOfAvailibility
	,[tg].useOfAvailabilityTarget AS AvgUseOfAvailibilityTarget
	,[ae].[availability] AS Availability
	,[tg].AvailabilityTarget
	,[t].Location
FROM [tyr].[CONOPS_TYR_TRUCK_DETAIL_V] [t] WITH (NOLOCK)
LEFT JOIN [tyr].[CONOPS_TYR_TP_AVG_PAYLOAD_V] [payload] WITH (NOLOCK) 
	ON [t].shiftflag = [payload].shiftflag
	AND [t].siteflag = [payload].siteflag
	AND [t].TruckID = [payload].TRUCK
LEFT JOIN TruckTons [tt] 
	ON [t].shiftid = [tt].shiftid
	AND [t].siteflag = [tt].siteflag
	AND [t].TruckID = [tt].TruckId
LEFT JOIN [tyr].[CONOPS_TYR_TP_DELTA_C_AVG_V] [dc] WITH (NOLOCK)
	ON [t].shiftindex = [dc].shiftindex
	AND [t].TruckID = [dc].truck
LEFT JOIN AE ae
	ON ae.shiftflag = t.shiftflag
	AND ae.eqmt = t.TruckID
LEFT JOIN TruckLoad [tl]
	ON [tl].Shiftindex = [t].shiftindex
	AND [tl].truck = [t].truckid
LEFT JOIn [tyr].[CONOPS_TYR_DELTA_C_TARGET_V] [tg]
	ON [t].shiftid = [tg].ShiftId



