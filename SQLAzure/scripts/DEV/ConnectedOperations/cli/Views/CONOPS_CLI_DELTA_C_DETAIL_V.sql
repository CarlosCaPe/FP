CREATE VIEW [cli].[CONOPS_CLI_DELTA_C_DETAIL_V] AS


  

   
--select * from [CLI].[CONOPS_CLI_DELTA_C_DETAIL_V] 
CREATE VIEW [CLI].[CONOPS_CLI_DELTA_C_DETAIL_V] 
AS

WITH DeltaC AS (
SELECT
	dc.shiftindex,
	TRUCK AS TruckId,
	CASE WHEN dc.DUMPNAME NOT LIKE '%CSP%'
		AND dc.DUMPNAME NOT LIKE '%GRAVEL%'
		AND dc.DUMPNAME NOT LIKE '%SNW%'
		AND dc.DUMPNAME NOT LIKE '%SNOW%'
		AND dc.DUMPNAME NOT LIKE '%SLS%'
		AND dc.DUMPNAME NOT LIKE '%INPIT%'
		AND dc.DUMPNAME NOT LIKE '%IN PIT%'
	THEN 'EXPIT'
	ELSE r.FieldId
	END AS PushBack,
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
LEFT JOIN [cli].PIT_LOC_C loc WITH (NOLOCK)
	ON dc.DUMPNAME = loc.FieldId
	AND dc.SHIFTINDEX = loc.SHIFTINDEX
	AND dc.SITE_CODE = 'CLI' 
	AND loc.siteflag = 'CMX'
LEFT JOIN [cli].PIT_LOC_C r WITH (NOLOCK)   
	ON r.Id = loc.FieldRegion
	AND r.SHIFTINDEX = loc.SHIFTINDEX AND r.siteflag = loc.siteflag
WHERE site_code = 'CLI'),

Targets AS (
SELECT 
	8.6 AS DeltaCTarget,
	2.12 AS idletimetarget,
	1.1 AS SpottingTarget,
	8.3 AS LoadingTarget,
	3.73 AS DumpingTarget,
	22.9 AS emptytraveltarget,
	11.4 AS loadedtraveltarget,
	2.48 AS DumpingAtStockpileTarget,
	1.25 AS DumpingAtCrusherTarget
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
FROM [CLI].CONOPS_CLI_SHIFT_INFO_V a
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
FROM [CLI].CONOPS_CLI_SHIFT_INFO_V a
LEFT JOIN DeltaC b ON a.SHIFTINDEX = b.SHIFTINDEX
CROSS JOIN Targets d
WHERE b.PushBack IS NOT NULL




  

