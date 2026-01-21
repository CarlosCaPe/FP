CREATE VIEW [SIE].[CONOPS_SIE_DAILY_TRUCK_POPUP_V] AS



-- SELECT * FROM [sie].[CONOPS_SIE_DAILY_TRUCK_POPUP_V] WITH (NOLOCK) WHERE [shiftflag] = 'CURR'  
CREATE VIEW [sie].[CONOPS_SIE_DAILY_TRUCK_POPUP_V]   
AS  
  
WITH TruckTons AS (
	SELECT sd.shiftid
		,sd.siteflag
		,t.FieldId AS [TruckId]
		,SUM(sd.FieldLsizetons) AS [Tons]
	FROM SIE.SHIFT_DUMP sd WITH (NOLOCK)
	LEFT JOIN SIE.shift_eqmt t WITH (NOLOCK) ON t.Id = sd.FieldTruck
	GROUP BY sd.shiftid
		,t.FieldId
		,sd.siteflag
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
	FROM [sie].[CONOPS_SIE_DAILY_TRUCK_ASSET_EFFICIENCY_PER_TRUCK_V] WITH (NOLOCK)
),

DCTarget AS (
	SELECT TOP 1
		--substring(replace(DateEffective,'-',''),3,4) as shiftdate,  
		substring(replace(cast(getdate() AS DATE), '-', ''), 3, 4) AS shiftdate
		,DeltaC AS Delta_c_target
		,EquivalentFlatHaul AS EFHtarget
		,spoting AS spottarget
		,idletime AS idletimetarget
		,(DumpingAtCrusher + DumpingatStockpile) AS dumpingtarget
		,DumpingAtCrusher AS dumpingAtCrusherTarget
		,DumpingatStockpile AS dumpingatStockpileTarget
		,LOADEDTRAVEL AS LoadedTravelTarget
		,EMPTYTRAVEL AS EmptyTraveltarget
		,TRUCKUSEOFAVAILABILITY AS useOfAvailabilityTarget
		,TRUCKAVAILABILITY AS AvailabilityTarget
	FROM [sie].[plan_values_prod_sum] WITH (NOLOCK)
	ORDER BY DateEffective DESC
	)
	,LOADTIME
AS (
	SELECT shiftid
		,truckid
		,LoadTarget
	FROM [sie].[CONOPS_SIE_DAILY_TRUCK_DETAIL_V] truck WITH (NOLOCK)
	LEFT JOIN (
		SELECT
			--substring(replace(DateEffective,'-',''),3,4) as shiftdate,  
			substring(replace(cast(getdate() AS DATE), '-', ''), 3, 4) AS shiftdate
			,CASE 
				WHEN ShovelId LIKE '%S43%'
					THEN 'S43'
				WHEN ShovelId LIKE '%S44%'
					THEN 'S44'
				WHEN ShovelId LIKE '%S48%'
					THEN 'S48'
				WHEN ShovelId LIKE '%S45%'
					THEN 'S45'
				WHEN ShovelId LIKE '%L50%'
					THEN 'L50'
				WHEN ShovelId LIKE '%L98%'
					THEN 'L98'
				END AS Shovelid
			,LoadTarget
		FROM (
			SELECT TOP 1 S43LOADING
				,S44LOADING
				,S48LOADING
				,S45LOADING
				,L50LOADING
				,L98LOADING
			FROM [sie].[plan_values_prod_sum] WITH (NOLOCK)
			ORDER BY DateEffective DESC
			) shv
		unpivot(LoadTarget FOR ShovelId IN (S43LOADING, S44LOADING, S48LOADING, S45LOADING, L50LOADING, L98LOADING)) unpiv
		) shovel ON truck.AssignedShovel = shovel.shovelid
),

TruckLoad AS (
	SELECT Shiftindex
		,truck
		,avg(EmptyTravelTarget) EmptyTravelTarget
		,avg(LoadedTravelTarget) LoadedTravelTarget
	FROM [sie].[CONOPS_SIE_EQMT_TRUCK_LOAD_DELTAC_V]
	GROUP BY shiftindex
		,truck
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
	,COALESCE([payload].AVG_Payload, 0) AS [Payload]
	,COALESCE([payload].Target, 0) [PayloadTarget]
	,COALESCE([tt].[Tons] / 1000.0, 0) [TotalMaterialDelivered]
	,NULL [TotalMaterialDeliveredTarget]
	,COALESCE(DeltaC, 0) AS DeltaC
	,COALESCE([dct].Delta_c_target, 0) AS DeltaCTarget
	,COALESCE(idletime, 0) AS IdleTime
	,[dct].idletimetarget AS IdleTimeTarget
	,COALESCE(spottime, 0) AS Spotting
	,spottarget AS SpottingTarget
	,COALESCE(loadtime, 0) AS Loading
	,[lt].loadtarget AS LoadingTarget
	,COALESCE(DumpingTime, 0) AS Dumping
	,[dct].dumpingtarget AS DumpingTarget
	,COALESCE(EFH, 0) AS Efh
	,COALESCE([dct].EFHtarget, 0) AS EfhTarget
	,COALESCE(DumpingAtStockpile, 0) AS [DumpsAtStockpile]
	,[dct].dumpingatStockpileTarget AS DumpsAtStockpileTarget
	,COALESCE(DumpingAtCrusher, 0) AS DumpsAtCrusher
	,[dct].dumpingAtCrusherTarget AS DumpsAtCrusherTarget
	,COALESCE(LoadedTravel,