CREATE VIEW [sie].[CONOPS_SIE_EQMT_TRUCK_HOURLY_DELTAC_V] AS



--select * from [sie].[CONOPS_SIE_EQMT_TRUCK_HOURLY_DELTAC_V] where shiftflag = 'prev' and equipment = '708'
CREATE VIEW [sie].[CONOPS_SIE_EQMT_TRUCK_HOURLY_DELTAC_V]
AS

WITH CTE AS (
	SELECT 
		shiftindex,
		truck AS Equipment,
		deltac_ts,
		AVG(delta_c) AS delta_c,
		AVG(TRUCK_IDLEDELTA) AS idletime,
		AVG(SPOTDELTA) AS spottime,
		AVG(LOADDELTA) AS loadtime,
		AVG(distloaded + (fliftup * 27.1428) + (fliftdown * 16)) AS EFH,
		AVG(LT_DELTA) AS LoadedTravel,
		AVG(ET_DELTA) AS EmptyTravel,
		AVG(DUMPINGDELTA) AS DumpingAtStockpile,
		AVG(CRUSHERDELTA) AS DumpingAtCrusher
	FROM dbo.delta_c WITH (NOLOCK)
	WHERE site_code = 'SIE'
	GROUP BY site_code, shiftindex, truck, deltac_ts
)

SELECT 
	shiftflag,
	siteflag,
	Equipment,
	b.deltac_ts,
	ROUND(delta_c, 2) AS DeltaC,
	ROUND(idletime, 2) AS idletime,
	ROUND(spottime, 2) AS Spotting,
	ROUND(loadtime, 2) AS Loading,
	ROUND(EFH, 0) AS EFH,
	ROUND(LoadedTravel, 2) AS LoadedTravel,
	ROUND(EmptyTravel, 2) AS EmptyTravel,
	ROUND(DumpingAtCrusher, 2) AS DumpingAtCrusher,
	ROUND(DumpingAtStockpile, 2) AS DumpingAtStockpile
FROM [SIE].CONOPS_SIE_SHIFT_INFO_V a
LEFT JOIN CTE b ON a.shiftindex = b.shiftindex 



