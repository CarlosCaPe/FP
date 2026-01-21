CREATE VIEW [mor].[CONOPS_MOR_SHOVEL_TPRH_V] AS

--select * from [mor].[CONOPS_MOR_SHOVEL_TPRH_V] where shiftflag = 'curr'
CREATE VIEW [MOR].[CONOPS_MOR_SHOVEL_TPRH_V] 
AS

WITH CTE AS (
SELECT
	site_code,
	shiftindex,
	EQMT,
	SUM(ReadyTime) / 3600.00 AS ReadyHour
FROM(
	SELECT 
		HOS.site_code,
		HOS.shiftindex,
		HOS.EQMT,
		CASE WHEN HOS.category IN ('1','2') THEN HOS.duration ELSE 0 END AS ReadyTime
	FROM mor.EQUIPMENT_HOURLY_STATUS (NOLOCK) AS HOS
	WHERE HOS.UNIT = '2' 
) AS sub1
GROUP BY site_code, shiftindex ,eqmt 
),

Tons AS (
SELECT 
	siteflag,
	shiftindex,
	excav,
	SUM(FieldLSizeTons) AS loadTons,
	COUNT(*) AS LoadCount
FROM MOR.SHIFT_LOAD_DETAIL_V (NOLOCK)
GROUP BY siteflag, shiftindex, excav
)

SELECT
	site_code,
	a.shiftindex,
	excav AS EQMT,
	loadcount,
	loadtons,
	readyhour,
	CASE WHEN readyhour = 0 OR readyhour IS NULL THEN 0
		ELSE loadtons/readyhour
	END AS TPRH
FROM Tons a
LEFT JOIN CTE b
	ON a.shiftindex = b.shiftindex
	AND a.excav = b.eqmt

