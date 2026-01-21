CREATE VIEW [bag].[CONOPS_BAG_EQMT_PAYLOAD_CATEGORY_V] AS

  
  
-- SELECT * FROM [bag].[CONOPS_BAG_EQMT_PAYLOAD_CATEGORY_V] WHERE shiftindex = '38821'
CREATE VIEW [bag].[CONOPS_BAG_EQMT_PAYLOAD_CATEGORY_V]
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
 ON a.SHIFT_ID = b.SHIFTID),

CAT AS (
SELECT
shiftindex,
ShovelId,
CASE WHEN eqmttype = 'CAT 793B' AND measureton BETWEEN 150 AND 244 THEN 'UnderLoaded'
WHEN eqmttype = 'CAT 793B' AND measureton BETWEEN 245 AND 257 THEN 'BelowTarget'
WHEN eqmttype = 'CAT 793B' AND measureton BETWEEN 258 AND 285 THEN 'OnTarget'
WHEN eqmttype = 'CAT 793B' AND measureton BETWEEN 286 AND 299 THEN 'AboveTarget'
WHEN eqmttype = 'CAT 793B' AND measureton BETWEEN 300 AND 400 THEN 'OverLoaded'

WHEN eqmttype = 'CAT 793D' AND measureton BETWEEN 150 AND 244 THEN 'UnderLoaded'
WHEN eqmttype = 'CAT 793D' AND measureton BETWEEN 245 AND 257 THEN 'BelowTarget'
WHEN eqmttype = 'CAT 793D' AND measureton BETWEEN 258 AND 285 THEN 'OnTarget'
WHEN eqmttype = 'CAT 793D' AND measureton BETWEEN 286 AND 299 THEN 'AboveTarget'
WHEN eqmttype = 'CAT 793D' AND measureton BETWEEN 300 AND 400 THEN 'OverLoaded'

WHEN eqmttype = 'CAT 793C' AND measureton BETWEEN 150 AND 244 THEN 'UnderLoaded'
WHEN eqmttype = 'CAT 793C' AND measureton BETWEEN 245 AND 257 THEN 'BelowTarget'
WHEN eqmttype = 'CAT 793C' AND measureton BETWEEN 258 AND 285 THEN 'OnTarget'
WHEN eqmttype = 'CAT 793C' AND measureton BETWEEN 286 AND 299 THEN 'AboveTarget'
WHEN eqmttype = 'CAT 793C' AND measureton BETWEEN 300 AND 400 THEN 'OverLoaded'

WHEN eqmttype = 'CAT 789' AND measureton BETWEEN 100 AND 171 THEN 'UnderLoaded'
WHEN eqmttype = 'CAT 789' AND measureton BETWEEN 172 AND 181 THEN 'BelowTarget'
WHEN eqmttype = 'CAT 789' AND measureton BETWEEN 182 AND 200 THEN 'OnTarget'
WHEN eqmttype = 'CAT 789' AND measureton BETWEEN 201 AND 209 THEN 'AboveTarget'
WHEN eqmttype = 'CAT 789' AND measureton BETWEEN 210 AND 350 THEN 'OverLoaded'

ELSE 'InvalidPayload' END AS Category
FROm cte
GROUP BY shiftindex,ShovelId,eqmttype,measureton),

TotalCat AS (
SELECT
shiftindex,
ShovelId,
COUNT(Category) AS CatTotal
FROm CAT
--WHERE Category <> 'InvalidPayload'
--AND shiftindex = '38821'
GROUP BY shiftindex,ShovelId),

CatTotal AS (
SELECT
shiftindex,
ShovelId,
CASE WHEN Category = 'UnderLoaded' THEN COUNT(ShovelId) ELSE 0 END AS UnderLoaded,
CASE WHEN Category = 'BelowTarget' THEN COUNT(ShovelId) ELSE 0 END AS BelowTarget,
CASE WHEN Category = 'OnTarget' THEN COUNT(ShovelId) ELSE 0 END AS OnTarget,
CASE WHEN Category = 'AboveTarget' THEN COUNT(ShovelId) ELSE 0 END AS AboveTarget,
CASE WHEN Category = 'OverLoaded' THEN COUNT(ShovelId) ELSE 0 END AS OverLoaded,
CASE WHEN Category = 'InvalidPayload' THEN COUNT(ShovelId) ELSE 0 END AS InvalidPayload
FROM CAT 
GROUP BY 
shiftindex,
ShovelId,
Category),

Actual AS (

SELECT
a.shiftindex,
a.ShovelId,
260 PayloadTarget,
(SUM(CAST(a.UnderLoaded AS FLOAT))/CAST(b.CatTotal AS FLOAT)) * 100 AS UnderLoaded,
(SUM(CAST(a.BelowTarget AS FLOAT))/CAST(b.CatTotal AS FLOAT)) * 100 AS BelowTarget,
(SUM(CAST(a.OnTarget AS FLOAT))/CAST(b.CatTotal AS FLOAT)) * 100 AS OnTarget,
(SUM(CAST(a.AboveTarget AS FLOAT))/CAST(b.CatTotal AS FLOAT)) * 100 AS AboveTarget,
(SUM(CAST(a.OverLoaded AS FLOAT))/CAST(b.CatTotal AS FLOAT)) * 100 AS OverLoaded,
(SUM(CAST(a.InvalidPayload AS FLOAT))/CAST(b.CatTotal AS FLOAT)) * 100 AS InvalidPayload
FROM CatTotal a
LEFT JOIN TOtalCat b ON a.SHIFTINDEX = b.SHIFTINDEX AND a.ShovelId = b.ShovelId
GROUP BY 
a.shiftindex,
a.ShovelId,
b.CatTotal),

CatTarget AS (
SELECT
shiftindex,   
ShovelId,
(PayloadTarget * 0.05) UnderloadedTarget
FROM Actual)

SELECT
ac.shiftindex,
ac.ShovelId,
UnderLoaded,
UnderloadedTarget,
BelowTarget,
O