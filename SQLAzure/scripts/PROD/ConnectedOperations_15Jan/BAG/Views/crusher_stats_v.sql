CREATE VIEW [BAG].[crusher_stats_v] AS

--SELECT * FROM [bag].[crusher_stats_v] WITH (NOLOCK)
CREATE VIEW [bag].[crusher_stats_v]
AS
  
WITH CrLocShift AS (
SELECT
	a.SHIFTINDEX,
	a.SITEFLAG,
	'CRUSHER 2' AS CrusherLoc
FROM [bag].[CONOPS_BAG_SHIFT_INFO_V] a WITH (NOLOCK)
WHERE a.SHIFTFLAG = 'CURR'
),

WaitingForCrusher AS (
SELECT
	siteflag,
	shiftindex,
	'CRUSHER 2' AS CrusherLoc,
	COUNT(EquipmentID) AS NoOfTruckWaiting
FROM bag.fleet_pit_machine_v
WHERE EquipmentCategory = 'Truck Classes'
AND Location LIKE '%Crusher%'
AND StatusCode IN (2,3,4,6)
GROUP BY siteflag, shiftindex
)

SELECT cl.siteflag,
	   cl.SHIFTINDEX,
	   cl.CrusherLoc,
	   ISNULL(wc.NoOfTruckWaiting, 0) NoOfTruckWaiting,
	   FORMAT(GETUTCDATE(), 'yyyy-MM-dd HH:mm:00') GeneratedUTCDate
FROM CrLocShift cl
LEFT JOIN WaitingForCrusher wc
ON cl.SHIFTINDEX = wc.SHIFTINDEX
	  AND cl.CrusherLoc = wc.CrusherLoc

