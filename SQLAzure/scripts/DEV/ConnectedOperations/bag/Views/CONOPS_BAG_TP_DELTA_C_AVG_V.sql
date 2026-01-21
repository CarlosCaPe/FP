CREATE VIEW [bag].[CONOPS_BAG_TP_DELTA_C_AVG_V] AS




--SELECT * FROM [bag].[CONOPS_BAG_TP_DELTA_C_AVG_V] where truck = 'T126'
CREATE VIEW [bag].[CONOPS_BAG_TP_DELTA_C_AVG_V]
AS

SELECT a.site_code
	,a.shiftindex
	,a.truck
	,avg(a.deltac) AS deltac
	,avg(a.idletime) AS idletime
	,avg(a.spottime) AS spottime
	,avg(a.loadtime) AS loadtime
	,avg(a.dumpingtime) AS dumpingtime
	,avg(f.DumpingAtStockpile) AS DumpingAtStockpile
	,avg(g.DumpingAtCrusher) AS DumpingAtCrusher
	,avg(a.LoadedTravel) AS LoadedTravel
	,avg(a.EmptyTravel) AS EmptyTravel
	,a.EFH
FROM (
	SELECT site_code
		,shiftindex
		,truck
		,avg(delta_c) AS deltac
		,avg(idletime) AS idletime
		,avg(spottime) AS spottime
		,avg(loadtime) AS loadtime
		,avg(DumpingTime) AS DumpingTime
		,avg(TRAVELLOADED) AS LoadedTravel
		,avg(TRAVELEMPTY) AS EmptyTravel
		,avg(distloaded + (fliftup * 27.1428) + (fliftdown * 16)) AS EFH
	FROM dbo.delta_c WITH (NOLOCK)
	WHERE site_code = 'BAG'
	GROUP BY site_code
		,shiftindex
		,truck
	) a
LEFT JOIN (
	SELECT shiftindex
		,truck
		,CASE WHEN unit = 'Stockpile' THEN COALESCE(avg([DUMPINGTIME]), 0) END AS DumpingAtStockpile
	FROM dbo.delta_c WITH (NOLOCK)
	WHERE site_code = 'BAG'
	GROUP BY site_code
		,shiftindex
		,truck
		,unit
	) f ON a.shiftindex = f.shiftindex
	AND a.truck = f.truck
LEFT JOIN (
	SELECT shiftindex
		,truck
		,CASE WHEN unit = 'Crusher' THEN COALESCE(avg([DUMPINGTIME]), 0) END AS DumpingAtCrusher
	FROM dbo.delta_c WITH (NOLOCK)
	WHERE site_code = 'BAG'
	GROUP BY site_code
		,shiftindex
		,truck
		,unit
	) g ON a.shiftindex = g.shiftindex
	AND a.truck = g.truck
WHERE a.site_code = 'BAG'
GROUP BY a.site_code
	,a.shiftindex
	,a.truck
	,a.efh




