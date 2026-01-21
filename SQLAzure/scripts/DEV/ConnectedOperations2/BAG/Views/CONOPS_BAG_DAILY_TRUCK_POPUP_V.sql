CREATE VIEW [BAG].[CONOPS_BAG_DAILY_TRUCK_POPUP_V] AS

-- SELECT * FROM [bag].[CONOPS_BAG_DAILY_TRUCK_POPUP_V] WITH (NOLOCK) WHERE [shiftflag] = 'CURR'
CREATE VIEW [bag].[CONOPS_BAG_DAILY_TRUCK_POPUP_V]
AS

WITH TruckTons AS (
	SELECT SITE_CODE AS SITEFLAG
		,SHIFT_ID AS SHIFTID
		,TRUCK_NAME AS TRUCKID
		,COALESCE(SUM(REPORT_PAYLOAD_SHORT_TONS), 0) AS Tons
	FROM BAG.FLEET_TRUCK_CYCLE_V
	GROUP BY SITE_CODE
		,SHIFT_ID
		,TRUCK_NAME
),

AE AS (
	SELECT shiftflag
		,shiftid
		,[siteflag]
		,eqmt
		,FORMAT(availability_pct, '##0.##') AS availability
		,CASE 
			WHEN availability_pct IS NULL
				OR availability_pct = 0
				THEN FORMAT(0, '##0.##')
			ELSE FORMAT(ROUND((ISNULL(Ops_efficient_pct, 0) / availability_pct * 100), 2), '##0.##')
			END [use_of_availability]
	FROM [bag].[CONOPS_BAG_DAILY_TRUCK_ASSET_EFFICIENCY_PER_TRUCK_V] WITH (NOLOCK)
	),

DCTarget AS (
	SELECT TOP 1 substring(replace(EffectiveDate, '-', ''), 3, 4) AS shiftdate
		,TotalDeltaC AS Delta_c_target
		--,EFH AS EFHtarget
		,'1.1' AS spottarget
		,'2.5' AS loadtarget
		,'2.12' AS idletimetarget
		,'2.5' AS dumpingtarget
		,'1.25' AS dumpingAtCrusherTarget
		,'1.25' AS dumpingatStockpileTarget
		,TRUCKLOADEDTRAVEL AS LoadedTravelTarget
		,TRUCKEMPTYTRAVEL AS EmptyTravelTarget
		,TRUCKUSEOFAVAILABILITY AS useOfAvailabilityTarget
		,TRUCKAVAILABILITY AS AvailabilityTarget
	FROM [bag].[plan_values_prod_sum] WITH (NOLOCK)
	ORDER BY EffectiveDate DESC
),

TruckLoad AS (  
	SELECT
		Shiftindex,
		truck,
		avg(LoadingTarget) LoadingTarget,
		avg(EmptyTravelTarget) EmptyTravelTarget,
		avg(LoadedTravelTarget) LoadedTravelTarget
	FROM [bag].[CONOPS_BAG_EQMT_TRUCK_LOAD_DELTAC_V]
	GROUP BY shiftindex,truck
),

EFHTarget AS(
SELECT 
	FORMATSHIFTID,
	EFH as EFHtarget
FROM [bag].[plan_values] with (nolock)
)

SELECT DISTINCT [t].shiftflag
	,[t].siteflag
	,[t].shiftid
	,[t].shiftindex
	,[t].TruckID
	,[t].eqmttype
	,UPPER([t].Operator) Operator
	,[t].OperatorId
	,[t].OperatorImageURL
	,[t].StatusName
	,[t].ReasonId
	,[t].ReasonDesc
	,ISNULL([payload].AVG_Payload, 0) AS [Payload]
	,ISNULL([payload].Target, 0) [PayloadTarget]
	,ISNULL([tt].[Tons] / 1000.0, 0) [TotalMaterialDelivered]
	,NULL [TotalMaterialDeliveredTarget]
	,ISNULL(DeltaC, 0) AS DeltaC
	,ISNULL(Delta_c_target, 0) AS DeltaCTarget
	,ISNULL(idletime, 0) AS IdleTime
	,idletimetarget AS IdleTimeTarget
	,ISNULL(spottime, 0) AS Spotting
	,spottarget AS SpottingTarget
	,ISNULL(loadtime, 0) AS Loading
	,[tl].LoadingTarget AS LoadingTarget
	,ISNULL(DumpingTime, 0) AS Dumping
	,dumpingtarget AS DumpingTarget
	,ISNULL([dc].LoadedTravel, 0) AS LoadedTravel
	,[tl].LoadedTravelTarget
	,ISNULL([dc].EmptyTravel, 0) AS EmptyTravel
	,[tl].EmptyTravelTarget
	,ISNULL(EFH, 0) AS Efh
	,ISNULL(EFHtarget, 0) AS EfhTarget
	,ISNULL(DumpingAtStockpile, 0) AS [DumpsAtStockpile]
	,dumpingatStockpileTarget AS DumpsAtStockpileTarget
	,ISNULL(DumpingAtCrusher, 0) AS DumpsAtCrusher
	,dumpingAtCrusherTarget AS DumpsAtCrusherTarget
	,[ae].[use_of_availability] AS AvgUseOfAvailibility
	,ISNULL(useOfAvailabilityTarget, 0) AS AvgUseOfAvailibilityTarget
	,[ae].[availability] AS Availability
	,ISNULL(AvailabilityTarget, 0) AS AvailabilityTarget
	,[t].Location
FROM [bag].[CONOPS_BAG_DAILY_TRUCK_DETAIL_V] [t] WITH (NOLOCK)
LEFT JOIN [bag].[CONOPS_BAG_DAILY_TP_AVG_PAYLOAD_V] [payload] WITH (NOLOCK) 
	ON [t].shiftindex = [payload].shiftindex
	AND [t].siteflag = [payload].siteflag
	AND [t].TruckID = [payload].TRUCK
LEFT JOIN TruckTons [tt]
	ON [t].shiftid = [tt].shiftid
	AND [t].TruckID = [tt].TruckId
LEFT JOIN [bag].[CONOPS_BAG_TP_DELTA_C_AVG_V] [dc] WITH (NOLOCK) 
	ON [t].shiftindex = [dc].shiftindex
	AND [t].TruckID = [dc].truck
LEFT JOIN AE ae
	ON ae.shiftflag = t.shiftflag
	AND ae.eqmt = t.TruckID
LEFT JOIN TruckLoad [tl]
	ON [tl].Shiftindex = [t].shiftindex
	AND [tl].truck = [t].truckid
CROSS JOIN DCTarget
LEFT JOIN EFHTarget et
	ON et.FORMATSHIFTID = t.shiftid



