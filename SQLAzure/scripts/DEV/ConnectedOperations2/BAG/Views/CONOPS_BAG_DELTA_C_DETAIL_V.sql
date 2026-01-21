CREATE VIEW [BAG].[CONOPS_BAG_DELTA_C_DETAIL_V] AS

  


--select * from [bag].[CONOPS_BAG_DELTA_C_DETAIL_V] 
CREATE VIEW [bag].[CONOPS_BAG_DELTA_C_DETAIL_V] 
AS

WITH DeltaC AS (
SELECT
	dc.shiftindex,
	TRUCK AS TruckId,
	CASE WHEN LEFT(grade,4) BETWEEN '0000' AND '9999'
		THEN SUBSTRING(grade,6,2)
		ELSE grade
	END AS PushBack,
	delta_c AS deltac,
	TRUCK_IDLEDELTA AS idletime,
	SPOTDELTA AS spotting,
	LOADDELTA AS loading,
	DUMPDELTA AS Dumping,
	ET_DELTA AS EmptyTravel,
	LT_DELTA AS LoadedTravel,
	CASE WHEN unit = 'Stockpile' THEN COALESCE([dumpdelta], 0) END AS DumpingAtStockpile,
	CASE WHEN unit = 'Crusher' THEN COALESCE([dumpdelta], 0) END AS DumpingAtCrusher,
	IDLETIME AS IdleTimeDuration,
	SPOTTIME AS SpottingDuration,
	LOADTIME AS LoadingDuration,
	DUMPINGTIME AS DumpingDuration,
	CASE WHEN unit = 'Stockpile' THEN COALESCE(DUMPINGTIME, 0) END AS DumpingAtStockpileDuration,
	CASE WHEN unit = 'Crusher' THEN COALESCE(DUMPINGTIME, 0) END AS DumpingAtCrusherDuration,
	TravelEmpty,
	TravelLoaded  
FROM dbo.delta_c dc WITH (NOLOCK)
WHERE site_code = 'BAG'),

Targets AS (
SELECT
	--FORMATSHIFTID AS SHIFTID,
	B.TotalDeltaC as DeltaCTarget,
	AVG(SPOTTINGDELTACTARGET) AS SpottingTarget,
	AVG(LOADINGDELTACTARGET) AS LoadingTarget,
	AVG(DUMPINGDELTACTARGET) AS dumpingtarget,
	AVG(QUEUEDELTACTARGET) AS idletimetarget,
	AVG(LOADEDTRAVELDELTACTARGET) AS loadedtraveltarget,
	AVG(EMPTYTRAVELDELTACTARGET) AS emptytraveltarget,
	AVG(DUMPINGATCRUSHER) AS dumpingAtCrusherTarget,
	AVG(STOCKPILETARGETS) AS dumpingatStockpileTarget
FROM [BAG].[PLAN_VALUES] A WITH (NOLOCK)
CROSS JOIN (SELECT TOP 1 TotalDeltaC FROM [bag].[plan_values_prod_sum] WITH (nolock) ORDER BY EffectiveDate DESC) B
GROUP BY TotalDeltaC)

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
FROM [BAG].CONOPS_BAG_SHIFT_INFO_V a
LEFT JOIN DeltaC b ON a.SHIFTINDEX = b.SHIFTINDEX
CROSS JOIN Targets d

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
FROM [BAG].CONOPS_BAG_SHIFT_INFO_V a
LEFT JOIN DeltaC b ON a.SHIFTINDEX = b.SHIFTINDEX
CROSS JOIN Targets d
WHERE b.PushBack IS NOT NULL





  

