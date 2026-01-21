CREATE VIEW [SIE].[CONOPS_SIE_DELTA_C_DETAIL_V] AS



--select * from [SIE].[CONOPS_SIE_DELTA_C_DETAIL_V] 
CREATE VIEW [SIE].[CONOPS_SIE_DELTA_C_DETAIL_V] 
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
LEFT JOIN sie.SHIFT_INFO si WITH (NOLOCK)
	ON dc.SHIFTDATE = si.SHIFTDATE
	AND dc.shift_code = RIGHT(si.shiftid, 1)
LEFT JOIN [SIE].shift_loc loc
	ON dc.DUMPNAME = loc.FieldId
	AND si.shiftid = loc.shiftid
	AND dc.SITE_CODE = loc.siteflag
LEFT JOIN [SIE].shift_loc r
	ON r.Id = loc.FieldRegion
	AND r.shiftid = loc.shiftid
	AND r.siteflag = loc.siteflag
WHERE dc.site_code = 'SIE'
),

Targets AS (
SELECT TOP 1
	DeltaC AS DeltaCTarget,
	1.1 AS SpottingTarget,
	(dumpingatcrusher + dumpingatstockpile) AS dumpingtarget,
	dumpingatcrusher AS DumpingatCrusherTarget,
	dumpingatstockpile AS dumpingatstockpileTarget,
	idletime AS idletimetarget,
	LOADEDTRAVEL AS loadedtraveltarget, 
	EMPTYTRAVEL AS emptytraveltarget
FROM [sie].[plan_values_prod_sum] (NOLOCK)
ORDER BY DateEffective DESC
),

LoadTime AS (
SELECT 
	AVG(LoadTimeTarget) AS LoadingTarget
FROM (
	SELECT TOP 1
		S43LOADING, S44LOADING, S48LOADING, S45LOADING, L50LOADING, L98LOADING
	FROM [sie].[plan_values_prod_sum]
	ORDER BY DateEffective DESC
	) shv
UNPIVOT (
LoadTimeTarget FOR ShovelId IN (S43LOADING, S44LOADING, S48LOADING, S45LOADING, L50LOADING, L98LOADING)
) unpiv
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
FROM [SIE].CONOPS_SIE_SHIFT_INFO_V a
LEFT JOIN DeltaC b ON a.SHIFTINDEX = b.SHIFTINDEX
CROSS JOIN Targets d
CROSS JOIN LoadTime e

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
FROM [SIE].CONOPS_SIE_SHIFT_INFO_V a
LEFT JOIN DeltaC b ON a.SHIFTINDEX = b.SHIFTINDEX
CROSS JOIN Targets d
CROSS JOIN LoadTime e
WHERE b.PushBack IS NOT NULL;


