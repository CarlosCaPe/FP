CREATE VIEW [ABR].[CONOPS_ABR_EQMT_TRUCK_LOAD_DELTAC_V] AS






-- SELECT * FROM [ABR].[CONOPS_ABR_EQMT_TRUCK_LOAD_DELTAC_V] WHERE SHIFTFLAG = 'PREV'
CREATE VIEW [ABR].[CONOPS_ABR_EQMT_TRUCK_LOAD_DELTAC_V]
AS

SELECT 
	shiftindex,
	truck,
	trktype,
	excav,
	shvtype,
	loaddelta,
	loadtime AS Loading,
	loadtime - loaddelta as LoadingTarget,
	TravelEmpty AS EmptyTravel,
	TravelEmpty - ET_DELTA AS EmptyTravelTarget,
	TravelLoaded AS LoadedTravel,
	TravelLoaded - LT_DELTA AS LoadedTravelTarget
FROM dbo.delta_c  WITH (NOLOCK)
WHERE site_code='ELA'





