CREATE VIEW [MOR].[CONOPS_MOR_EQMT_PAYLOAD_CATEGORY_V] AS
  
  
-- SELECT * FROM [mor].[CONOPS_MOR_EQMT_PAYLOAD_CATEGORY_V] WHERE shiftindex = '38820'  
CREATE VIEW [mor].[CONOPS_MOR_EQMT_PAYLOAD_CATEGORY_V]  
AS  
  
WITH CTE AS (  
select  
t.SHIFTINDEX,  
t.fieldid as TruckId,  
REPLACE(enum.[description],' ','') as eqmttype,  
s.FieldId AS ShovelId,  
ld.measureton  
FROM [mor].[pit_truck_c] [t] WITH (NOLOCK)  
LEFT JOIN [mor].[pit_excav_c] [s] WITH (NOLOCK)  
ON [t].fieldexcav = [s].Id AND [t].SHIFTINDEX = [s].SHIFTINDEX  
LEFT JOIN dbo.LH_LOAD ld WITH (NOLOCK) ON t.SHIFTINDEX = ld.SHIFTINDEX AND s.FieldId = ld.excav AND ld.SITE_CODE = 'MOR'  
left join mor.enum enum WITH (NOLOCK)on enum.id = t.FieldEqmttype),  
  
CAT AS (  
SELECT  
shiftindex,  
ShovelId,  
CASE WHEN eqmttype = 'CAT793B' AND measureton BETWEEN 150 AND 244 THEN 'UnderLoaded'  
WHEN eqmttype = 'CAT793B' AND measureton BETWEEN 245 AND 257 THEN 'BelowTarget'  
WHEN eqmttype = 'CAT793B' AND measureton BETWEEN 258 AND 285 THEN 'OnTarget'  
WHEN eqmttype = 'CAT793B' AND measureton BETWEEN 286 AND 299 THEN 'AboveTarget'  
WHEN eqmttype = 'CAT793B' AND measureton BETWEEN 300 AND 400 THEN 'OverLoaded'  
  
WHEN eqmttype = 'CAT793D' AND measureton BETWEEN 150 AND 244 THEN 'UnderLoaded'  
WHEN eqmttype = 'CAT793D' AND measureton BETWEEN 245 AND 257 THEN 'BelowTarget'  
WHEN eqmttype = 'CAT793D' AND measureton BETWEEN 258 AND 285 THEN 'OnTarget'  
WHEN eqmttype = 'CAT793D' AND measureton BETWEEN 286 AND 299 THEN 'AboveTarget'  
WHEN eqmttype = 'CAT793D' AND measureton BETWEEN 300 AND 400 THEN 'OverLoaded'  
  
WHEN eqmttype = 'CAT793C' AND measureton BETWEEN 150 AND 244 THEN 'UnderLoaded'  
WHEN eqmttype = 'CAT793C' AND measureton BETWEEN 245 AND 257 THEN 'BelowTarget'  
WHEN eqmttype = 'CAT793C' AND measureton BETWEEN 258 AND 285 THEN 'OnTarget'  
WHEN eqmttype = 'CAT793C' AND measureton BETWEEN 286 AND 299 THEN 'AboveTarget'  
WHEN eqmttype = 'CAT793C' AND measureton BETWEEN 300 AND 400 THEN 'OverLoaded'  
  
WHEN eqmttype = 'CAT789' AND measureton BETWEEN 100 AND 171 THEN 'UnderLoaded'  
WHEN eqmttype = 'CAT789' AND measureton BETWEEN 172 AND 181 THEN 'BelowTarget'  
WHEN eqmttype = 'CAT789' AND measureton BETWEEN 182 AND 200 THEN 'OnTarget'  
WHEN eqmttype = 'CAT789' AND measureton BETWEEN 201 AND 209 THEN 'AboveTarget'  
WHEN eqmttype = 'CAT789' AND measureton BETWEEN 210 AND 350 THEN 'OverLoaded'  
  
ELSE 'InvalidPayload' END AS Category  
FROm cte  
GROUP BY shiftindex,ShovelId,eqmttype,measureton),  
  
TotalCat AS (  
SELECT  
shiftindex,  
ShovelId,  
COUNT(Category) AS CatTotal  
FROm CAT  
WHERE Category <> 'InvalidPayload'  
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
Category)  
  
SELECT  
a.shiftindex,  
a.ShovelId,  
(SUM(CAST(a.UnderLoaded AS FLOAT))/CAST(b.CatTotal AS FLOAT)) * 100 AS UnderLoaded,  
(SUM(CAST(a.BelowTarget AS FLOAT))/CAST(b.CatTotal AS FLOAT)) * 100 AS BelowTarget,  
(SUM(CAST(a.OnTarget AS FLOAT))/CAST(b.CatTotal AS FLOAT)) * 100 AS OnTarget,  
(SUM(CAST(a.AboveTarget AS FLOAT))/CAST(b.CatTotal AS FLOAT)) * 100 AS AboveTarget,  
(SUM(CAST(a.OverLoaded AS FLOAT))/CAST(b.CatTotal AS FLOAT)) * 100 AS OverLoaded,  
(SUM(CAST(a.InvalidPayload AS FLOAT))/CAST(b.CatTotal AS FLOAT)) * 100 AS InvalidPayload  
FROM CatTotal a  
LEFT JOIN TOtalCat b ON a.SHIFTINDEX = b.SHIFTINDEX AND a.ShovelI