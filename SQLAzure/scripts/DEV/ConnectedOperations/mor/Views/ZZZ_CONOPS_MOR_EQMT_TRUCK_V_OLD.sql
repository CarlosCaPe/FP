CREATE VIEW [mor].[ZZZ_CONOPS_MOR_EQMT_TRUCK_V_OLD] AS




-- SELECT * FROM [mor].[CONOPS_MOR_EQMT_TRUCK_V] WITH (NOLOCK) WHERE shiftflag = 'PREV'  ORDER BY shiftflag, siteflag, TruckId
CREATE VIEW [mor].[CONOPS_MOR_EQMT_TRUCK_V_OLD]
AS

WITH TonsPerHaul AS (
	SELECT [ShiftId]
		,[Truck]
		,[tonsHaul]
	FROM [mor].[CONOPS_MOR_TRUCK_TPRH] WITH (NOLOCK)
),

ShiftInfo AS (
	SELECT [SiteFlag]
		,[ShiftFlag]
		,[ShiftId]
		,[ShiftIndex]
	FROM [mor].[CONOPS_MOR_SHIFT_INFO_V] WITH (NOLOCK)
),


uofa AS (
	SELECT [shiftid]
		,[shiftflag]
		,[eqmt]
		,[use_of_availability_pct] AS [Utilization]
	FROM [mor].[CONOPS_MOR_TRUCK_ASSET_EFFICIENCY_PER_TRUCK_V] WITH (NOLOCK)
),

EmpTravelTar AS (
	SELECT TOP 1
		substring( replace( [DateEffective], '-', ''), 1, 4) as [shiftdate]
		,[EmptyTravel] AS EmptyTravelTarget
	FROM [mor].[plan_values_prod_sum]
	ORDER BY [modified] DESC
),

DeltaC AS (
	SELECT [si].[shiftid]
		,[SHIFT_CODE]
		,[TRUCK]
		,[EmptyTravel]
		,[eTravTar].[EmptyTravelTarget]
	FROM (
		SELECT [SHIFTINDEX]
			,[SHIFT_CODE]
			,[TRUCK]
			,AVG([TRAVELEMPTY]) AS [EmptyTravel]
			,substring( replace( [shiftdate], '-', ''), 1, 4) AS [shiftdate]
		FROM [dbo].[delta_c] WITH (NOLOCK)
		WHERE SITE_CODE = 'MOR'
		GROUP BY [TRUCK], [SHIFTINDEX], [SHIFT_CODE], [shiftdate]
	) [dc]
	LEFT JOIN [EmpTravelTar] AS [eTravTar]
		ON [dc].shiftdate = [eTravTar].[shiftdate]
	LEFT JOIN [ShiftInfo] [si]
		ON [dc].[SHIFTINDEX] = [si].[SHIFTINDEX]
),

EqmtStat AS (
	SELECT [shiftid],
		[eqmt],
		startdatetime,
		[status] AS eqmtcurrstatus,
		[Duration],
		ROW_NUMBER() OVER ( PARTITION BY [shiftid], [eqmt]
							  ORDER BY startdatetime DESC ) num
	FROM [mor].[asset_efficiency_v] WITH (NOLOCK)
	WHERE [UnitType] = 'Truck'
),

TotalMD AS (
	SELECT se.shiftid,
		fieldid,
		COALESCE(sum(FieldLsizetons), 0) as TotalMaterialDelivered
	FROM [mor].[SHIFT_EQMT] se WITH (NOLOCK)
	LEFT JOIN [mor].[SHIFT_DUMP_v] sd
		ON se.shiftid = sd.shiftid
		AND se.id = sd.FieldTruck
	WHERE FieldUnit = 263
	GROUP BY se.shiftid, se.FIELDID
)

SELECT [truck].[shiftflag]
	,[truck].[siteflag]
	,[truck].[ShiftId]
    ,[truck].[TruckID]
    ,[Operator]
    ,[OperatorImageURL]
    ,[StatusName]
    ,[ReasonId]
    ,[ReasonDesc]
    ,[Payload]
    ,[PayloadTarget]
    --,[TotalMaterialDelivered]
    --,COALESCE([TotalMaterialDeliveredTarget], 0) AS [TotalMaterialDeliveredTarget]
    ,[DeltaC]
    ,[DeltaCTarget]
    ,[IdleTime]
    ,[IdleTimeTarget]
    ,[Spotting]
    ,[SpottingTarget]
    ,[Loading]
    ,[LoadingTarget]
    ,[Dumping]
    ,[DumpingTarget]
    ,[DumpsAtStockpile]
    ,[DumpsAtStockpileTarget]
	,COALESCE([tmd].[TotalMaterialDelivered], 0) AS [TotalMaterialDelivered]
	,COALESCE([ttmd].[TotalMaterialDeliveredTarget], 0) AS [TotalMaterialDeliveredTarget]
	,[Efh]
	,[EfhTarget]
	,[AvgUseOfAvailibility]
	,[AvgUseOfAvailibilityTarget]
    ,[DumpsAtCrusher]
    ,[DumpsAtCrusherTarget]
    ,[Location]
	,COALESCE([tprh].[TonsHaul], 0) AS [TonsHaul]
	, 0 AS [TonsHaulTarget] -- NEED TO CHECK IF THERE IS A TARGET
	,COALESCE([uofa].[Utilization], 0) AS [Utilization]
	,COALESCE([dc].[EmptyTravel], 0) AS [EmptyTravel]
	,COALESCE([dc].[EmptyTravelTarget], 0) AS [EmptyTravelTarget]
	,[es].[duration]
FROM [mor].[CONOPS_MOR_TRUCK_POPUP_V] [truck] WITH (NOLOCK)
LEFT JOIN [mor].[CONOPS_MOR_TRUCK_TOTAL_MATERIAL_DELIVERED_V] [ttmd] 
	ON [truck].[ShiftId] = [ttmd].[shiftid]
	AND [truck].[TruckID] = [ttmd].[truckid]
LEFT JOIN TotalMD [tmd]
	ON [truck].[ShiftId] = [tmd].[ShiftId]
	AND [truck].[TruckID] = [tmd].[fieldid]
LEFT JOIN TonsPerHaul [tprh]
	ON [truck].[ShiftId] = [tprh].[ShiftId]
	AND [truck].[TruckID] = [tprh].[Truck]
LEFT JOIN uofa
	ON [truck].[shiftflag] = [uofa].[shiftflag]
	AND [truck].[TruckID] = [uofa].[eqmt]
LEFT JOIN DeltaC [dc]
	ON [uofa].[ShiftId] = [dc].[ShiftId]
	AND [truck].[TruckID] = [dc].[TRUCK]
LEFT JOIN [EqmtStat] [es]
	ON [truck].[ShiftId] = [es].[shiftid]
	AND [truck].[TruckID] = [e