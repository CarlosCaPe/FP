CREATE VIEW [MOR].[CONOPS_MOR_DELTA_C_DETAIL_V] AS



--select * from [MOR].[CONOPS_MOR_DELTA_C_DETAIL_V] 
CREATE VIEW [MOR].[CONOPS_MOR_DELTA_C_DETAIL_V] 
AS

WITH DeltaC AS (
SELECT
	shiftindex,
	TruckId,
	CASE 
		WHEN PushBack LIKE '%WT%' THEN 'W COPPER 10'
		WHEN PushBack LIKE '%WF%' THEN 'W COPPER 14'
		WHEN PushBack LIKE '%SR%' THEN 'SUN RIDGE MINE'
		WHEN PushBack LIKE '%AM%' THEN 'AMT MINE'
		WHEN PushBack LIKE '%WC%' THEN 'W COPPER'
		WHEN PushBack LIKE 'GAR%' THEN 'GAR DUMPS'
		WHEN PushBack LIKE 'SD%' THEN 'SLV DUMPS'
		WHEN PushBack LIKE 'GF%' THEN 'GARFIELD MINE'
		WHEN PushBack LIKE 'LR%' THEN 'LRH DUMPS'
		WHEN PushBack LIKE 'CO%' THEN 'CORONADO'
		WHEN PushBack LIKE 'ILL%' OR PushBack LIKE '%ML2%' THEN 'MILL'
		WHEN PushBack LIKE 'FL%' THEN 'MFL'
		WHEN PushBack LIKE 'SH%' THEN 'SHANNON'
	ELSE PushBack
	END AS PushBack,
	deltac,
	idletime,
	spotting,
	loading,
	Dumping,
	EmptyTravel,
	LoadedTravel,
	TravelEmpty,
	TravelLoaded,
	DumpingAtStockpile,
	DumpingAtCrusher,
	IdleTimeDuration,
	SpottingDuration,
	LoadingDuration,
	DumpingDuration,
	DumpingAtStockpileDuration,
	DumpingAtCrusherDuration
	FROM (
	SELECT
		dc.shiftindex,
		TRUCK AS TruckId,
		REPLACE(SUBSTRING(grade, 6, 3), '-', '') AS PushBack,
		delta_c AS deltac,
		TRUCK_IDLEDELTA AS idletime,
		SPOTDELTA AS spotting,
		LOADDELTA AS loading,
		DUMPDELTA AS Dumping,
		ET_DELTA AS EmptyTravel,
		LT_DELTA AS LoadedTravel,
		DUMPINGDELTA AS DumpingAtStockpile,
		CRUSHERDELTA AS DumpingAtCrusher,
		IDLETIME AS IdleTimeDuration,
		SPOTTIME AS SpottingDuration,
		LOADTIME AS LoadingDuration,
		COALESCE(DUMPINGTIME,0) + COALESCE(CRUSHERIDLE,0) AS DumpingDuration,
		DUMPINGTIME AS DumpingAtStockpileDuration,
		CRUSHERIDLE AS DumpingAtCrusherDuration,
		TravelEmpty,
		TravelLoaded
	FROM dbo.delta_c dc WITH (NOLOCK)
	WHERE site_code = 'MOR'
	) a
),

Targets AS (
SELECT
	DateEffective,
	DeltaC AS DeltaCTarget,
	spoting AS SpottingTarget,
	loading AS LoadingTarget,
	1.1 AS idletimetarget,
	(DeltaCDumpCr + DeltaCDumpStk) AS dumpingtarget,
	DeltaCDumpCr AS DumpingAtCrusherTarget,
	DeltaCDumpStk AS DumpingatStockpileTarget,
	deltacloadedtravel AS loadedtraveltarget,
	deltacemptytravel AS emptytraveltarget
FROM [mor].[plan_values_prod_sum] (NOLOCK)
)

SELECT
	a.shiftflag,
	a.siteflag,
	TruckId,
	'Overall' AS PushBack,
	DeltaC,
	DeltaCTarget,
	IdleTime,
	Idletimetarget,
	IdleTimeDuration,
	Spotting,
	SpottingTarget,
	SpottingDuration,
	Loading,
	LoadingTarget,
	LoadingDuration,
	Dumping,
	DumpingTarget,
	DumpingDuration,
	EmptyTravel,
	TravelEmpty - EmptyTravel AS Emptytraveltarget,
	TravelEmpty AS EmptyTravelDuration, 
	emptytraveltarget AS EmptyTravelPlan,
	LoadedTravel,
	TravelLoaded - LoadedTravel AS Loadedtraveltarget,
	TravelLoaded AS LoadedTravelDuration,
	loadedtraveltarget AS LoadedTravelPlan,
	DumpingAtStockpile,
	DumpingAtStockpileTarget,
	DumpingAtStockpileDuration,
	DumpingAtCrusher,
	DumpingAtCrusherTarget,
	DumpingAtCrusherDuration
FROM [MOR].CONOPS_MOR_SHIFT_INFO_V a
LEFT JOIN DeltaC b 
	ON a.SHIFTINDEX = b.SHIFTINDEX
LEFT JOIN Targets d
	ON FORMAT(a.ShiftStartDate, 'yyyy-MM') = FORMAT(d.DateEffective, 'yyyy-MM')

UNION

SELECT
	a.shiftflag,
	a.siteflag,
	Truckid,
	b.PushBack,
	DeltaC,
	DeltaCTarget,
	IdleTime,
	Idletimetarget,
	IdleTimeDuration,
	Spotting,
	SpottingTarget,
	SpottingDuration,
	Loading,
	LoadingTarget,
	LoadingDuration,
	Dumping,
	DumpingTarget,
	DumpingDuration,
	EmptyTravel,
	TravelEmpty - EmptyTravel AS Emptytraveltarget,
	TravelEmpty AS EmptyTravelDuration, 
	emptytraveltarget AS EmptyTravelPlan,
	LoadedTravel,
	TravelLoaded - LoadedTravel AS Loadedtraveltarget,
	TravelLoaded AS LoadedTravelDuration,
	loadedtraveltarget AS LoadedTravelPlan,
	DumpingAtStockpile,
	DumpingAtStockpileTarget,
	DumpingAtStockpileDuration,
	DumpingAtCrusher,
	DumpingAtCrusherTarget,
	DumpingAtCrusherDuration
FROM [MOR].CONOPS_MOR_SHIFT_INFO_V a
LEFT JO