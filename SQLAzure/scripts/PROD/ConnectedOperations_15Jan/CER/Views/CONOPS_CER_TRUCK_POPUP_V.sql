CREATE VIEW [CER].[CONOPS_CER_TRUCK_POPUP_V] AS



-- SELECT * FROM [cer].[CONOPS_CER_TRUCK_POPUP_V] WITH (NOLOCK) WHERE [shiftflag] = 'CURR'  
CREATE VIEW [cer].[CONOPS_CER_TRUCK_POPUP_V]  
AS  
  
WITH TruckTons
AS (
	SELECT sd.shiftid
		,sd.siteflag
		,t.FieldId AS [TruckId]
		,SUM(sd.FieldLsizetons) AS [Tons]
	FROM cer.SHIFT_DUMP_V sd WITH (NOLOCK)
	LEFT JOIN cer.shift_eqmt t WITH (NOLOCK) ON t.shift_eqmt_id = sd.FieldTruck
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
	FROM [cer].[CONOPS_CER_TRUCK_ASSET_EFFICIENCY_PER_TRUCK_V] WITH (NOLOCK)
),

DCTarget AS (
	SELECT TOP 1 *
	FROM [cer].[CONOPS_CER_DELTA_C_TARGET_V] WITH (NOLOCK)
	ORDER BY shiftid DESC
	),
	
DCTargetAvailability AS (
	SELECT TOP 1 ps.SITEFLAG
		,cast((AVAILABILITYTOTALTRUCK) AS DECIMAL(5, 2)) * 100 AS AvailabilityTarget
	FROM [CER].[PLAN_VALUES] ps WITH (NOLOCK)
	WHERE TITLE = FORMAT(GETDATE(), 'MMM yyyy', 'en-US')
),

TruckLoad AS (
	SELECT Shiftindex
		,truck
		,avg(LoadingTarget) LoadingTarget
		,avg(EmptyTravelTarget) EmptyTravelTarget
		,avg(LoadedTravelTarget) LoadedTravelTarget
	FROM [cer].[CONOPS_CER_EQMT_TRUCK_LOAD_DELTAC_V]
	GROUP BY shiftindex
		,truck
)

SELECT [t].shiftflag
	,[t].siteflag
	,[t].shiftid
	,[t].SHIFTINDEX
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
	,COALESCE([dct].Delta_c_target, 0) AS DeltaCTarget
	,COALESCE(idletime, 0) AS IdleTime
	,COALESCE([dct].idletimetarget, '1.1') AS IdleTimeTarget
	,COALESCE(spottime, 0) AS Spotting
	,COALESCE(spottarget, 0) AS SpottingTarget
	,COALESCE(loadtime, 0) AS Loading
	,COALESCE([tl].LoadingTarget, 0) AS LoadingTarget
	,COALESCE(DumpingTime, 0) AS Dumping
	,COALESCE([dct].dumpingtarget, 0) AS DumpingTarget
	,COALESCE(EFH, 0) AS Efh
	,COALESCE([dct].EFHtarget, 0) AS EfhTarget
	,COALESCE(DumpingAtStockpile, 0) AS [DumpsAtStockpile]
	,COALESCE([dct].dumpingatStockpileTarget, 0) AS DumpsAtStockpileTarget
	,COALESCE(DumpingAtCrusher, 0) AS DumpsAtCrusher
	,COALESCE([dct].dumpingAtCrusherTarget, 0) AS DumpsAtCrusherTarget
	,COALESCE(LoadedTravel, 0) AS LoadedTravel
	,COALESCE([tl].LoadedTravelTarget, 0) AS LoadedTravelTarget
	,COALESCE(EmptyTravel, 0) AS EmptyTravel
	,COALESCE([tl].EmptyTravelTarget, 0) AS EmptyTravelTarget
	,[ae].[use_of_availability] AS AvgUseOfAvailibility
	,COALESCE(useOfAvailabilityTarget, 0) * 100 AS AvgUseOfAvailibilityTarget
	,[ae].[availability] AS Availability
	,COALESCE([dcta].AvailabilityTarget, 0) AS AvailabilityTarget
	,[t].[Location]
FROM [cer].[CONOPS_CER_TRUCK_DETAIL_V] [t] WITH (NOLOCK)
LEFT JOIN [cer].[CONOPS_CER_TP_AVG_PAYLOAD_V] [payload] WITH (NOLOCK) ON [t].shiftflag = [payload].shiftflag
	AND [t].siteflag = [payload].siteflag
	AND [t].TruckID = [payload].TRUCK
LEFT JOIN TruckTons [tt] ON [t].shiftid = [tt].shiftid
	AND [t].siteflag = [tt].siteflag
	AND [t].TruckID = [tt].TruckId
LEFT JOIN [cer].[CONOPS_CER_TP_DELTA_C_AVG_V] [dc] WITH (NOLOCK) ON [t].shiftindex = [dc].shiftindex
	AND [t].TruckID = [dc].truck
LEFT JOIN TruckLoad [tl] ON [tl].Shiftindex = [t].shiftindex
	AND [tl].truck = [t].truckid
LEFT JOIN AE ae ON ae.shiftflag = t.shiftflag
	AND ae.eqmt = t.TruckID
CROSS JOIN DCTarget [dct]
CROSS JOIN DCTargetAvailability [dcta]



