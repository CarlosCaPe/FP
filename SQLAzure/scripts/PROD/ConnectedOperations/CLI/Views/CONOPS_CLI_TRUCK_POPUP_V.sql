CREATE VIEW [CLI].[CONOPS_CLI_TRUCK_POPUP_V] AS


-- SELECT * FROM [cli].[CONOPS_CLI_TRUCK_POPUP_V] WITH (NOLOCK) WHERE [shiftflag] = 'CURR'  
CREATE VIEW [cli].[CONOPS_CLI_TRUCK_POPUP_V]   
AS  
  
WITH TruckTons AS (
	SELECT sd.shiftid
		,sd.siteflag
		,t.FieldId AS [TruckId]
		,SUM(sd.FieldLsizetons) AS [Tons]
	FROM CLI.SHIFT_DUMP sd WITH (NOLOCK)
	LEFT JOIN cli.shift_eqmt t WITH (NOLOCK) ON t.Id = sd.FieldTruck
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
	FROM [cli].[CONOPS_CLI_TRUCK_ASSET_EFFICIENCY_PER_TRUCK_V] WITH (NOLOCK)
),

DCTarget AS (
	SELECT TOP 1 8.6 Delta_c_target
		,2.12 idletimetarget
		,1.1 spottarget
		,8.3 loadtimetarget
		,3.73 dumpingtarget
		,ps.EFHtarget
		,2.48 dumpingatStockpileTarget
		,1.25 dumpingAtCrusherTarget
		,11.4 LoadedtravelTarget
		,22.9 EmptyTravelTarget
		,0 useOfAvailabilityTarget
		,av.AvailabilityTarget
	FROM (
		SELECT TOP 1 EFH AS EFHtarget
		FROM [cli].[plan_values] WITH (NOLOCK)
		ORDER BY shiftid DESC
		) ps
	CROSS JOIN (
		SELECT TOP 1 cast((TRUCKAVAILABILITY) AS DECIMAL(5, 2)) * 100 AS AvailabilityTarget
		FROM [CLI].[PLAN_VALUES_MONTHLY_TARGET] WITH (NOLOCK)
		ORDER BY ID DESC
		) av
),

TruckLoad AS (
	SELECT Shiftindex
		,truck
		,avg(LoadingTarget) LoadingTarget
		,avg(EmptyTravelTarget) EmptyTravelTarget
		,avg(LoadedTravelTarget) LoadedTravelTarget
	FROM [CLI].[CONOPS_CLI_EQMT_TRUCK_LOAD_DELTAC_V]
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
	,[dct].idletimetarget AS IdleTimeTarget
	,COALESCE(spottime, 0) AS Spotting
	,[dct].spottarget AS SpottingTarget
	,COALESCE(loadtime, 0) AS Loading
	,[tl].LoadingTarget AS LoadingTarget
	,COALESCE(DumpingTime, 0) AS Dumping
	,[dct].dumpingtarget AS DumpingTarget
	,COALESCE(EFH, 0) AS Efh
	,COALESCE([dct].EFHtarget, 0) AS EfhTarget
	,COALESCE(DumpingAtStockpile, 0) AS [DumpsAtStockpile]
	,[dct].dumpingatStockpileTarget AS DumpsAtStockpileTarget
	,COALESCE(DumpingAtCrusher, 0) AS DumpsAtCrusher
	,[dct].dumpingAtCrusherTarget AS DumpsAtCrusherTarget
	,COALESCE(LoadedTravel, 0) AS LoadedTravel
	,[tl].LoadedTravelTarget AS LoadedTravelTarget
	,COALESCE(EmptyTravel, 0) AS EmptyTravel
	,[tl].EmptyTravelTarget AS EmptyTravelTarget
	,[ae].[use_of_availability] AS AvgUseOfAvailibility
	,COALESCE([dct].useOfAvailabilityTarget, 0) AS AvgUseOfAvailibilityTarget
	,[ae].[availability] AS Availability
	,COALESCE([dct].AvailabilityTarget, 0) AS AvailabilityTarget
	,[t].Location
FROM [cli].[CONOPS_CLI_TRUCK_DETAIL_V] [t] WITH (NOLOCK)
LEFT JOIN [cli].[CONOPS_CLI_TP_AVG_PAYLOAD_V] [payload] WITH (NOLOCK) 
	ON [t].shiftflag = [payload].shiftflag
	AND [t].siteflag = [payload].siteflag
	AND [t].TruckID = [payload].TRUCK
LEFT JOIN TruckTons [tt] 
	ON [t].shiftid = [tt].shiftid
	AND [t].TruckID = [tt].TruckId
LEFT JOIN [cli].[CONOPS_CLI_TP_DELTA_C_AVG_V] [dc] WITH (NOLOCK) 
	ON [t].shiftindex = [dc].shiftindex
	AND [t].TruckID = [dc].truck
LEFT JOIN AE ae 
	ON ae.shiftflag = t.shiftflag
	AND ae.eqmt = t.TruckID
LEFT JOIN TruckLoad [tl] 
	ON [tl].Shiftindex = [t].shiftindex
	AND [tl].truck = [t].truckid
CROSS JOIN DCTarget [dct]
 


