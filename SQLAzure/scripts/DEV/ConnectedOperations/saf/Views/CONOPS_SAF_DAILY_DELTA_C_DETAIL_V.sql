CREATE VIEW [saf].[CONOPS_SAF_DAILY_DELTA_C_DETAIL_V] AS

  




--select * from [SAF].[CONOPS_SAF_DAILY_DELTA_C_DETAIL_V]
CREATE VIEW [SAF].[CONOPS_SAF_DAILY_DELTA_C_DETAIL_V] 
AS

WITH DeltaC AS (
SELECT
	dc.shiftindex,
	TRUCK AS TruckId,
	r.FieldId AS Pushback,
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
LEFT JOIN [SAF].PIT_LOC_C loc
	ON dc.DUMPNAME = loc.FieldId
	AND dc.SHIFTINDEX = loc.SHIFTINDEX
	AND dc.SITE_CODE = loc.siteflag
LEFT JOIN [SAF].PIT_LOC_C r
	ON r.Id = loc.FieldRegion
	AND r.SHIFTINDEX = loc.SHIFTINDEX 
	AND r.siteflag = loc.siteflag
WHERE site_code = 'SAF'),

Targets AS (
SELECT TOP 1 
	Delta_c_target as DeltaCTarget,
	spottarget as SpottingTarget, 
	loadtarget as LoadingTarget,
	idletimetarget as idletimetarget,
	dumpingtarget,
	DumpingAtCrusherTarget,
	DumpingatStockpileTarget,
	loadedtraveltarget,
	emptytraveltarget
FROM [saf].[CONOPS_SAF_DELTA_C_TARGET_V]
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
FROM [SAF].CONOPS_SAF_EOS_SHIFT_INFO_V a
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
FROM [SAF].CONOPS_SAF_EOS_SHIFT_INFO_V a
LEFT JOIN DeltaC b ON a.SHIFTINDEX = b.SHIFTINDEX
CROSS JOIN Targets d
WHERE b.PushBack IS NOT NULL




  

