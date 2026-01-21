CREATE VIEW [chi].[ZZZ_CONOPS_CHI_EQMT_TRUCK_V_OLD] AS





-- SELECT * FROM [chi].[CONOPS_CHI_EQMT_TRUCK_V] WITH (NOLOCK) WHERE shiftflag = 'CURR'  ORDER BY shiftflag, siteflag, TruckId
CREATE VIEW [chi].[CONOPS_CHI_EQMT_TRUCK_V_OLD]
AS

WITH TonsPerHaul AS (
	SELECT [ShiftId]
		,[Truck]
		,[tonsHaul]
	FROM [chi].[CONOPS_CHI_TRUCK_TPRH] WITH (NOLOCK)
),

ShiftInfo AS (
	SELECT [SiteFlag]
		,[ShiftFlag]
		,[ShiftId]
		,[ShiftIndex]
	FROM [chi].[CONOPS_CHI_SHIFT_INFO_V]  WITH (NOLOCK) 
),

uofa AS (
	SELECT [shiftid]
		,[shiftflag]
		,[eqmt]
		,[use_of_availability_pct] AS [Utilization]
	FROM [chi].[CONOPS_CHI_TRUCK_ASSET_EFFICIENCY_PER_TRUCK_V] WITH (NOLOCK)
),

EmpTravelTar AS (
	SELECT TOP 1
		[siteflag]
		,[PlannedEmptyTravelTime] AS EmptyTravelTarget
	FROM [chi].[plan_values] WITH (NOLOCK)
	WHERE [PlannedEmptyTravelTime] IS NOT NULL
	ORDER BY ID DESC
),

DeltaC AS (
	SELECT [si].[shiftid]
		,[SHIFT_CODE]
		,[TRUCK]
		,[EmptyTravel]
		,COALESCE([eTravTar].[EmptyTravelTarget], 0 ) AS EmptyTravelTarget
	FROM (
		SELECT [SHIFTINDEX]
			,[SHIFT_CODE]
			,[site_code]
			,[TRUCK]
			,AVG([TRAVELEMPTY]) AS [EmptyTravel]
			,substring( replace( [shiftdate], '-', ''), 1, 4) AS [shiftdate]
		FROM [dbo].[delta_c] WITH (NOLOCK)
		WHERE SITE_CODE = 'CHI'
		GROUP BY [TRUCK], [SHIFTINDEX], [SHIFT_CODE], [shiftdate], [site_code]
	) [dc]
	LEFT JOIN [EmpTravelTar] AS [eTravTar]
		ON [dc].[site_code] = [eTravTar].[siteflag]
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
	FROM [chi].[asset_efficiency_v] WITH (NOLOCK)
	WHERE [UnitType] = 'Truck'
),

TotalMD AS (
	SELECT se.shiftid,
		fieldid,
		COALESCE(sum(FieldLsizetons), 0) as TotalMaterialDelivered
	FROM [chi].[SHIFT_EQMT] se WITH (NOLOCK)
	LEFT JOIN [chi].[SHIFT_DUMP_v] sd
		ON se.shiftid = sd.shiftid
		AND se.id = sd.FieldTruck
	WHERE FieldUnit = 281
	GROUP BY se.shiftid, se.FIELDID
)

SELECT [truck].[shiftflag]
	,[truck].[siteflag]
	,[truck].[ShiftId]
    ,[TruckID]
    ,[Operator]
    ,[OperatorImageURL]
    ,[StatusName]
    ,[ReasonId]
    ,[ReasonDesc]
    ,[Payload]
    ,[PayloadTarget]
    ,COALESCE([tmd].[TotalMaterialDelivered], 0) AS [TotalMaterialDelivered]
    ,COALESCE([TotalMaterialDeliveredTarget], 0) AS [TotalMaterialDeliveredTarget]
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
    ,[DumpsAtCrusher]
    ,[DumpsAtCrusherTarget]
    ,[Location]
	,COALESCE([tprh].[TonsHaul], 0) AS [TonsHaul]
	, 0 AS [TonsHaulTarget] -- NEED TO CHECK IF THERE IS A TARGET
	,COALESCE([uofa].[Utilization], 0) AS [Utilization]
	,COALESCE([dc].[EmptyTravel], 0) AS [EmptyTravel]
	,COALESCE([dc].[EmptyTravelTarget], 0) AS [EmptyTravelTarget]
	,COALESCE([es].[duration], 0) AS [duration]
	,15.5 AS [Score] -- * NEED TO CONFIRM TO BRYAN - NO UPDATES YET
FROM [chi].[CONOPS_CHI_TRUCK_POPUP_V] [truck] WITH (NOLOCK)
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
	ON [truck].[ShiftId] = [dc].[ShiftId]
	AND [truck].[TruckID] = [dc].[TRUCK]
LEFT JOIN [EqmtStat] [es]
	ON [truck].[ShiftId] = [es].[shiftid]
	AND [truck].[TruckID] = [es].[eqmt]
	AND [es].num = 1

