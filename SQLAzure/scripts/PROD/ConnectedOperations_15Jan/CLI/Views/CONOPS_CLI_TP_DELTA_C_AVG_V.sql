CREATE VIEW [CLI].[CONOPS_CLI_TP_DELTA_C_AVG_V] AS







--SELECT * FROM [cli].[CONOPS_CLI_TP_DELTA_C_AVG_V] 
CREATE VIEW [cli].[CONOPS_CLI_TP_DELTA_C_AVG_V]
AS

SELECT 
	a.site_code,
	a.shiftindex,
	a.truck,
	AVG(a.deltac) AS deltac,
	AVG(a.idletime) AS idletime,
	AVG(a.spottime) AS spottime,
	AVG(a.loadtime) AS loadtime,
	AVG(a.dumpingtime) AS dumpingtime,
	AVG(a.DumpingAtStockpile) AS DumpingAtStockpile,
	AVG(a.DumpingAtCrusher) AS DumpingAtCrusher,
	AVG(a.LoadedTravel) AS LoadedTravel,
	AVG(a.EmptyTravel) AS EmptyTravel,
	a.EFH
FROM (
	SELECT 
		site_code,
		shiftindex,
		truck,
		AVG(delta_c) AS deltac,
		AVG(idletime) AS idletime,
		AVG(spottime) AS spottime,
		AVG(loadtime) AS loadtime,
		AVG(COALESCE(DUMPINGTIME, 0) + COALESCE(CRUSHERIDLE, 0)) AS DumpingTime,
		AVG(TRAVELLOADED) AS LoadedTravel,
		AVG(TRAVELEMPTY) AS EmptyTravel,
		AVG(DUMPINGTIME) AS DumpingAtStockpile,
		AVG(CRUSHERIDLE) AS DumpingAtCrusher,
		AVG(distloaded + (fliftup * 27.1428) + (fliftdown * 16)) AS EFH
	FROM dbo.delta_c WITH (NOLOCK)
	WHERE site_code = 'CLI'
	GROUP BY site_code, shiftindex, truck
) a
WHERE a.site_code = 'CLI'
GROUP BY 
	a.site_code,
	a.shiftindex,
	a.truck,
	a.efh


