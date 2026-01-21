CREATE VIEW [TYR].[CONOPS_TYR_DELTA_C_DETAIL_V] AS




--select * from [tyr].[CONOPS_TYR_DELTA_C_DETAIL_V]   
CREATE VIEW [TYR].[CONOPS_TYR_DELTA_C_DETAIL_V]   
AS  
  
WITH DeltaC AS (  
SELECT  
	shiftindex,  
	TruckId,  
	PushBack,  
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
FROM(  
	SELECT  
		dc.shiftindex,  
		TRUCK AS TruckId,  
		REGION AS PushBack,  
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
	WHERE site_code = 'TYR'  
	) a  
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
FROM [tyr].CONOPS_TYR_SHIFT_INFO_V a  
LEFT JOIN DeltaC b ON a.SHIFTINDEX = b.SHIFTINDEX  
LEFT JOIN [tyr].[CONOPS_TYR_DELTA_C_TARGET_V] d  
ON a.shiftid = d.shiftid
  
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
FROM [tyr].CONOPS_TYR_SHIFT_INFO_V a  
LEFT JOIN DeltaC b ON a.SHIFTINDEX = b.SHIFTINDEX  
LEFT JOIN [tyr].[CONOPS_TYR_DELTA_C_TARGET_V]  d  
	ON a.SHIFTID = d.shiftid
WHERE b.PushBack IS NOT NULL  
  
  
  
  

  


