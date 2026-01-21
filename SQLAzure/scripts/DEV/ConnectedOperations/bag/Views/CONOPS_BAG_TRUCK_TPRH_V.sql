CREATE VIEW [bag].[CONOPS_BAG_TRUCK_TPRH_V] AS


--select * from [bag].[CONOPS_BAG_TRUCK_TPRH_V] where shiftflag = 'curr'

CREATE VIEW [bag].[CONOPS_BAG_TRUCK_TPRH_V] 
AS

WITH CTE AS (
SELECT
shiftindex,
eqmt,
SUM(ReadyTime) AS ReadyTime
FROM (
SELECT
shiftindex,
eqmt,
CASE WHEN category IN ('1','2') THEN duration ELSE 0 END AS ReadyTime
FROM bag.EQUIPMENT_HOURLY_STATUS
WHERE unit = 1) a
GROUP BY shiftindex, eqmt),

Tons AS (
SELECT 
shiftindex,
truck,
SUM(loadtons_us) AS loadTons
FROM DBO.LH_LOAD (NOLOCK)
WHERE Site_code = 'BAG'
GROUP BY site_code,shiftindex,truck)

SELECT 
a.SHIFTINDEX,
eqmt,
CASE WHEN ReadyTime != 0 THEN loadtons/(ReadyTime/3600.0) ELSE 0 END AS TPRH
FROM CTE a
LEFT JOIN Tons b ON a.SHIFTINDEX = b.SHIFTINDEX AND a.EQMT = b.TRUCK


