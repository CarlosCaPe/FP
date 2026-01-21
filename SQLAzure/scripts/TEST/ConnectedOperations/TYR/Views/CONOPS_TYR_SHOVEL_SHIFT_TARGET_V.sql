CREATE VIEW [TYR].[CONOPS_TYR_SHOVEL_SHIFT_TARGET_V] AS





--SELECT * FROM [tyr].[CONOPS_TYR_SHOVEL_SHIFT_TARGET_V]
CREATE VIEW [TYR].[CONOPS_TYR_SHOVEL_SHIFT_TARGET_V]
AS

WITH CTE AS (
SELECT
Formatshiftid,
CASE WHEN LoadingUnit like '%Shovel' THEN LEFT(LoadingUnit,2) 
ELSE LoadingUnit END AS ShovelID,
CASE WHEN Destination = 'MiningRateWaste' THEN 'Waste'
WHEN Destination = 'MiningRateROM' THEN 'ROM'
END AS Destination,
ShovelTarget
FROM [TYR].[PLAN_VALUES] WITH (NOLOCK) unpivot
( ShovelTarget FOR Destination IN (
MiningRateWaste,MiningRateROM)) unpiv
),


TGT AS (
SELECT
FormatShiftId AS shiftid, 
ShovelID,
Destination,
ShovelTarget,
0 AS ShovelShiftTarget
FROM CTE
WHERE ShovelID IS NOT NULL
)

SELECT
a.siteflag,
a.shiftflag,
a.shiftid,
b.ShovelID,
destination,
ROUND(SUM(b.ShovelShiftTarget),1) ShovelShiftTarget,
ROUND(((a.shiftduration/3600.0) / 12.0) * SUM(ShovelShiftTarget),1) AS ShovelTarget
FROM [tyr].[CONOPS_TYR_SHIFT_INFO_V] a
LEFT JOIN TGT b on a.shiftid = b.shiftid 
GROUP BY
a.siteflag,
a.shiftflag,
a.shiftid,
b.ShovelID,
destination,
a.shiftduration



