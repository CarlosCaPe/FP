CREATE VIEW [MOR].[CONOPS_MOR_TRUCK_POPUP_V] AS





-- SELECT * FROM [mor].[CONOPS_MOR_TRUCK_POPUP_V] WITH (NOLOCK) WHERE [shiftflag] = 'CURR'  
CREATE VIEW [mor].[CONOPS_MOR_TRUCK_POPUP_V]   
AS  
  
WITH TruckTons AS (
	SELECT sd.shiftid
		,sd.siteflag
		,t.FieldId AS [TruckId]
		,SUM(sd.FieldLsizetons) AS [Tons]
	FROM mor.shift_dump_v sd WITH (NOLOCK)
	LEFT JOIN mor.shift_eqmt t WITH (NOLOCK) ON t.Id = sd.FieldTruck
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
	FROM [mor].[CONOPS_MOR_TRUCK_ASSET_EFFICIENCY_PER_TRUCK_V] WITH (NOLOCK)
	),

DCTarget AS (
	SELECT 
		substring(replace(DateEffective, '-', ''), 3, 4) AS targetperiod
		,DeltaC AS Delta_c_target
		,EquivalentFlatHaul AS EFHtarget
		,spoting AS spottarget
		,loading AS loadtarget
		,loadedtravel AS loadedtraveltarget
		,emptytravel AS emptytraveltarget
		,(DumpingAtCrusher + DumpingatStockpile) AS dumpingtarget
		,DumpingAtCrusher AS dumpingAtCrusherTarget
		,DumpingatStockpile AS dumpingatStockpileTarget
		,ROUND((TruckAssetEfficiency / truckavailability), 2) * 100 AS useOfAvailabilityTarget
		,ROUND(TruckAvailability, 2) AS AvailabilityTarget
	FROM [mor].[plan_values_prod_sum] WITH (NOLOCK)
	),

TruckLoad AS (
	SELECT Shiftindex
		,truck
		,avg(LoadingTarget) LoadingTarget
		,avg(EmptyTravelTarget) EmptyTravelTarget
		,avg(LoadedTravelTarget) LoadedTravelTarget
	FROM [MOR].[CONOPS_MOR_EQMT_TRUCK_LOAD_DELTAC_V]
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
	,COALESCE(DCTarget.Delta_c_target, 0) AS DeltaCTarget
	,COALESCE(idletime, 0) AS IdleTime
	,'1.1' AS IdleTimeTarget
	,COALESCE(spottime, 0) AS Spotting
	,COALESCE(DCTarget.spottarget, 0) AS SpottingTarget
	,COALESCE(loadtime, 0) AS Loading
	,COALESCE([tl].LoadingTarget, 0) AS LoadingTarget
	,COALESCE(DumpingTime, 0) AS Dumping
	,COALESCE(DCTarget.dumpingtarget, 0) AS DumpingTarget
	,COALESCE(EFH, 0) AS Efh
	,COALESCE(DCTarget.EFHtarget, 0) AS EfhTarget
	,COALESCE(DumpingAtStockpile, 0) AS [DumpsAtStockpile]
	,COALESCE(DCTarget.dumpingatStockpileTarget, 0) AS DumpsAtStockpileTarget
	,COALESCE(DumpingAtCrusher, 0) AS DumpsAtCrusher
	,COALESCE(DCTarget.dumpingAtCrusherTarget, 0) AS DumpsAtCrusherTarget
	,COALESCE(LoadedTravel, 0) AS LoadedTravel
	,COALESCE([tl].LoadedTravelTarget, 0) AS LoadedTravelTarget
	,COALESCE(EmptyTravel, 0) AS EmptyTravel
	,COALESCE([tl].EmptyTravelTarget, 0) AS EmptyTravelTarget
	,[ae].[use_of_availability] AS AvgUseOfAvailibility
	,COALESCE([DCTarget].useOfAvailabilityTarget, 0) AS AvgUseOfAvailibilityTarget
	,[ae].[availability] AS Availability
	,COALESCE([DCTarget].AvailabilityTarget, 0) AS AvailabilityTarget
	,[t].Location
FROM [mor].[CONOPS_MOR_TRUCK_DETAIL_V] [t] WITH (NOLOCK)
LEFT JOIN [mor].[CONOPS_MOR_TP_AVG_PAYLOAD_V] [payload] WITH (NOLOCK) 
	ON [t].shiftindex = [payload].shiftindex
	AND [t].TruckID = [payload].TRUCK
LEFT JOIN TruckTons [tt] 
	ON [t].shiftid = [tt].shiftid
	AND [t].siteflag = [tt].siteflag
	AND [t].TruckID = [tt].TruckId
LEFT JOIN [mor].[CONOPS_MOR_TP_DELTA_C_AVG_V] [dc] WITH (NOLOCK) 
	ON [t].shiftindex = [dc].shiftindex
	AND [t].TruckID = [dc].truck
LEFT JOIN AE ae 
	ON t.shiftflag = ae.shiftflag
	AND t.TruckID = ae.eqmt
LEFT JOIN TruckLoad [tl