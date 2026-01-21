CREATE VIEW [CER].[CONOPS_CER_DELTA_C_DETAIL_V] AS



  


--select * from [CER].[CONOPS_CER_DELTA_C_DETAIL_V] 
CREATE VIEW [CER].[CONOPS_CER_DELTA_C_DETAIL_V] 
AS

WITH DeltaC AS (
SELECT
	dc.shiftindex,
	TRUCK AS TruckId,
	CONCAT(LEFT(grade, 2), RIGHT(grade, 2)) AS PushBack,
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
WHERE site_code = 'CER'),

Targets AS (
SELECT TOP 1
	Delta_c_target AS DeltaCTarget,
	spottarget AS SpottingTarget,
	loadtarget AS LoadingTarget,
	dumpingtarget,
	dumpingAtCrusherTarget,
	dumpingatStockpileTarget,
	idletimetarget,
	emptytraveltarget,
	loadedtraveltarget
FROM [cer].[CONOPS_CER_DELTA_C_TARGET_V]
ORDER BY shiftid DESC)

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
FROM [CER].CONOPS_CER_SHIFT_INFO_V a
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
	FROM [CER].CONOPS_CER_SHIFT_INFO_V a
LEFT JOIN DeltaC b ON a.SHIFTINDEX = b.SHIFTINDEX
CROSS JOIN Targets d
WHERE b.PushBack IS NOT NULL




  



