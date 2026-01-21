CREATE VIEW [BAG].[CONOPS_BAG_EQMT_TRUCK_HOURLY_DELTAC_V] AS



--select * from [bag].[CONOPS_BAG_EQMT_TRUCK_HOURLY_DELTAC_V] where shiftflag = 'prev' and equipment = '708'
CREATE VIEW [bag].[CONOPS_BAG_EQMT_TRUCK_HOURLY_DELTAC_V]
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
		AVG(LT_DELTA) AS LoadedTravel,
		AVG(ET_DELTA) AS EmptyTravel,
		AVG(distloaded + (fliftup * 27.1428) + (fliftdown * 16)) AS EFH
	FROM dbo.delta_c WITH (NOLOCK)
	WHERE site_code = 'BAG'
	GROUP BY site_code, shiftindex, truck, deltac_ts
),

DumpatCrusher AS (
	SELECT 
		shiftindex,
		truck,
		deltac_ts,
		CASE WHEN unit = 'Crusher' THEN COALESCE(AVG([dumpdelta]), 0) END AS DumpingAtCrusher
	FROM dbo.delta_c WITH (NOLOCK)
	WHERE site_code = 'BAG'
	GROUP BY site_code, shiftindex, truck, unit, deltac_ts
),

DumpatStockpile AS (
	SELECT 
		shiftindex,
		truck,
		deltac_ts,
		CASE WHEN unit = 'Stockpile' THEN COALESCE(AVG([dumpdelta]), 0) END AS DumpingAtStockpile 
	FROM dbo.delta_c WITH (NOLOCK)
	WHERE site_code = 'BAG'
	GROUP BY site_code, shiftindex, truck, unit, deltac_ts
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
FROM [bag].CONOPS_BAG_SHIFT_INFO_V a
LEFT JOIN CTE b ON a.shiftindex = b.shiftindex 
LEFT JOIN DumpatCrusher c ON a.SHIFTINDEX = c.SHIFTINDEX AND b.Equipment = c.TRUCK AND b.DELTAC_TS = c.DELTAC_TS
LEFT JOIN DumpatStockpile d ON a.SHIFTINDEX = d.SHIFTINDEX AND b.Equipment = d.TRUCK AND b.DELTAC_TS = d.DELTAC_TS



