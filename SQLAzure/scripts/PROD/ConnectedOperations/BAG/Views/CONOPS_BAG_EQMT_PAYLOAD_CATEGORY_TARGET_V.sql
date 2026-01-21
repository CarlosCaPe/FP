CREATE VIEW [BAG].[CONOPS_BAG_EQMT_PAYLOAD_CATEGORY_TARGET_V] AS

 
-- SELECT * FROM [bag].[CONOPS_BAG_EQMT_PAYLOAD_CATEGORY_TARGET_V] WHERE shiftindex = '38916'
CREATE VIEW [bag].[CONOPS_BAG_EQMT_PAYLOAD_CATEGORY_TARGET_V]
AS

WITH CTE AS (
SELECT  
 SITE_CODE,  
 SHIFT_ID AS SHIFTID,  
 b.SHIFTINDEX,  
 TRUCK_NAME AS TRUCKID,  
 TRUCK_EQUIP_CLASS AS EQMTTYPE,  
 SHOVEL_NAME AS SHOVELID,  
 MEASURED_PAYLOAD_SHORT_TONS AS MEASURETON  
FROM BAG.FLEET_TRUCK_CYCLE_V a WITH (NOLOCK)  
LEFT JOIN BAG.CONOPS_BAG_SHIFT_INFO_V b  
 ON a.SHIFT_ID = b.SHIFTID  
),

--Get Payload, UnderloadedTarget & TotalCount
PT AS (
SELECT
SHIFTINDEX,
ShovelId,
260 AS PayloadTarget,
0.05 * 260 AS UnderLoadedTarget,
FLOOR(260 - (0.05 * 260)) AS UnderLoaded,
COUNT(ShovelId) AS TotalCount
FROm CTE
GROUP BY SHIFTINDEX,ShovelId),

--Get OverLoaded & InvalidPayload
Category AS (
SELECT 
a.ShiftIndex,
a.ShovelId,
CASE WHEN a.measureton = UnderLoaded THEN COUNT(a.ShovelId) ELSE 0 END AS BelowTarget,
CASE WHEN a.measureton BETWEEN UnderLoaded AND 290 THEN COUNT(a.ShovelId) ELSE 0 END AS OnTarget,
CASE WHEN a.measureton BETWEEN PayloadTarget AND 290 THEN COUNT(a.ShovelId) ELSE 0 END AS AboveTarget,
CASE WHEN a.measureton > 290 THEN COUNT(a.ShovelId) ELSE 0 END AS OverLoaded,
CASE WHEN a.measureton < 200 THEN COUNT(a.ShovelId) ELSE 0 END AS InvalidPayload
FROM CTE a
LEFT JOIN PT b on a.SHIFTINDEX = b.SHIFTINDEX AND a.ShovelId = b.ShovelId
GROUP BY 
a.ShiftIndex,
a.ShovelId,
a.measureton,
PayloadTarget,
UnderLoaded),


--Get the percentage
Final AS (
SELECT
cat.ShiftIndex,
cat.ShovelId,
PayloadTarget,
UnderLoadedTarget,
ROUND(((SUM(CAST (BelowTarget AS FLOAT)) / TotalCount) * 100),2) AS BelowTargetTarget,
ROUND(((SUM(CAST (OnTarget AS FLOAT)) / TotalCount) * 100),2) AS OnTargetTarget,
ROUND(((SUM(CAST (AboveTarget AS FLOAT)) / TotalCount) * 100),2) AS AboveTargetTarget,
ROUND(((SUM(CAST (OverLoaded AS FLOAT)) / TotalCount) * 100),2) AS OverLoadedTarget,
ROUND(((SUM(CAST (InvalidPayload AS FLOAT)) / TotalCount) * 100),2) AS InvalidPayloadTarget
FROM PT pt
LEFT JOIN Category cat on pt.SHIFTINDEX = cat.SHIFTINDEX AND pt.ShovelId = cat.ShovelId
GROUP BY 
cat.ShiftIndex,
cat.ShovelId,
PayloadTarget,
UnderLoadedTarget,
TotalCount)

SELECT 
ShiftIndex,
ShovelId,
PayloadTarget,
UnderLoadedTarget,
BelowTargetTarget,
OnTargetTarget,
AboveTargetTarget,
OverLoadedTarget,
InvalidPayloadTarget
FROM Final
--WHERE ShiftIndex = '38917'
--AND ShovelId = 'S46'





  
  
  

