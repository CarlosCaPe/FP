CREATE VIEW [BAG].[CONOPS_BAG_SHOVEL_TPRH_V] AS

--select * from [bag].[CONOPS_BAG_SHOVEL_TPRH_V] where shiftflag = 'curr'
CREATE VIEW [BAG].[CONOPS_BAG_SHOVEL_TPRH_V] 
AS

WITH Ae AS(
SELECT
	SHIFTID,
	EQMT,
	SUM(DURATION) / 3600.00 AS ReadyHour
FROM bag.asset_efficiency with (nolock)
WHERE UNITTYPE IN ('Shovel','Loader')
	AND CATEGORYIDX IN (1,2)
GROUP BY SHIFTID, EQMT
),

Loads AS(
SELECT
	a.SITE_CODE,
	b.SHIFTINDEX,
	a.SHIFT_ID AS SHIFTID,
	SHOVEL_NAME AS EQMT,
	SUM(REPORT_PAYLOAD_SHORT_TONS) AS LOADTONS,
	COUNT(*) AS LOADCOUNT
FROM BAG.FLEET_SHOVEL_CYCLE_V a
RIGHT JOIN BAG.CONOPS_BAG_SHIFT_INFO_V b
	ON a.SHIFT_ID = b.SHIFTID
GROUP BY SHIFTFLAG, SITE_CODE, ShiftStartDateTime, SHIFT_ID, SHIFTINDEX, SHOVEL_NAME
)

SELECT 
	site_code,
	shiftindex,
	l.EQMT,
	loadcount,
	loadtons,
	readyhour,
	CASE WHEN readyhour = 0 OR readyhour IS NULL THEN 0 
		ELSE loadtons/readyhour
	END AS TPRH
FROM Loads l
LEFT JOIN Ae e
	ON l.SHIFTID = e.SHIFTID AND l.EQMT = e.EQMT

