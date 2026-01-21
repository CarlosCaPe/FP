CREATE VIEW [CER].[CONOPS_CER_EQMT_PAYLOAD_CATEGORY_V] AS
  
  
-- SELECT * FROM [cer].[CONOPS_CER_EQMT_PAYLOAD_CATEGORY_V] WHERE shiftindex = '38822'  
CREATE VIEW [cer].[CONOPS_CER_EQMT_PAYLOAD_CATEGORY_V]  
AS  
  
WITH CTE AS (  
select  
t.SHIFTINDEX,  
t.fieldid as TruckId,  
REPLACE(enum.[description],' ','') as eqmttype,  
s.FieldId AS ShovelId,  
ld.measureton  
FROM [cer].[pit_truck_c] [t] WITH (NOLOCK)  
LEFT JOIN [cer].[pit_excav_c] [s] WITH (NOLOCK)  
ON [t].fieldexcav = [s].Id AND [t].SHIFTINDEX = [s].SHIFTINDEX  
LEFT JOIN dbo.LH_LOAD ld WITH (NOLOCK) ON t.SHIFTINDEX = ld.SHIFTINDEX AND s.FieldId = ld.excav AND ld.SITE_CODE = 'CER'  
left join cer.enum enum WITH (NOLOCK)on enum.idx = t.FieldEqmttype),  
  
CAT AS (  
SELECT  
shiftindex,  
ShovelId,  
CASE WHEN eqmttype = 'CAT789A' AND measureton BETWEEN 100 AND 171 THEN 'UnderLoaded'  
WHEN eqmttype = 'CAT789A' AND measureton BETWEEN 172 AND 181 THEN 'BelowTarget'  
WHEN eqmttype = 'CAT789A' AND measureton BETWEEN 182 AND 200 THEN 'OnTarget'  
WHEN eqmttype = 'CAT789A' AND measureton BETWEEN 201 AND 209 THEN 'AboveTarget'  
WHEN eqmttype = 'CAT789A' AND measureton BETWEEN 210 AND 350 THEN 'OverLoaded'  
  
WHEN eqmttype = 'CAT789B' AND measureton BETWEEN 100 AND 171 THEN 'UnderLoaded'  
WHEN eqmttype = 'CAT789B' AND measureton BETWEEN 172 AND 181 THEN 'BelowTarget'  
WHEN eqmttype = 'CAT789B' AND measureton BETWEEN 182 AND 200 THEN 'OnTarget'  
WHEN eqmttype = 'CAT789B' AND measureton BETWEEN 201 AND 209 THEN 'AboveTarget'  
WHEN eqmttype = 'CAT789B' AND measureton BETWEEN 210 AND 350 THEN 'OverLoaded'  
  
WHEN eqmttype = 'CAT793B' AND measureton BETWEEN 150 AND 215 THEN 'UnderLoaded'  
WHEN eqmttype = 'CAT793B' AND measureton BETWEEN 216 AND 228 THEN 'BelowTarget'  
WHEN eqmttype = 'CAT793B' AND measureton BETWEEN 229 AND 252 THEN 'OnTarget'  
WHEN eqmttype = 'CAT793B' AND measureton BETWEEN 253 AND 265 THEN 'AboveTarget'  
WHEN eqmttype = 'CAT793B' AND measureton BETWEEN 266 AND 350 THEN 'OverLoaded'  
  
WHEN eqmttype = 'CAT793C' AND measureton BETWEEN 150 AND 215 THEN 'UnderLoaded'  
WHEN eqmttype = 'CAT793C' AND measureton BETWEEN 216 AND 228 THEN 'BelowTarget'  
WHEN eqmttype = 'CAT793C' AND measureton BETWEEN 229 AND 252 THEN 'OnTarget'  
WHEN eqmttype = 'CAT793C' AND measureton BETWEEN 253 AND 265 THEN 'AboveTarget'  
WHEN eqmttype = 'CAT793C' AND measureton BETWEEN 266 AND 350 THEN 'OverLoaded'  
  
WHEN eqmttype = 'CAT793D' AND measureton BETWEEN 150 AND 215 THEN 'UnderLoaded'  
WHEN eqmttype = 'CAT793D' AND measureton BETWEEN 216 AND 228 THEN 'BelowTarget'  
WHEN eqmttype = 'CAT793D' AND measureton BETWEEN 229 AND 252 THEN 'OnTarget'  
WHEN eqmttype = 'CAT793D' AND measureton BETWEEN 253 AND 265 THEN 'AboveTarget'  
WHEN eqmttype = 'CAT793D' AND measureton BETWEEN 266 AND 350 THEN 'OverLoaded'  
  
WHEN eqmttype = 'KOM930E' AND measureton BETWEEN 200 AND 270 THEN 'UnderLoaded'  
WHEN eqmttype = 'KOM930E' AND measureton BETWEEN 271 AND 285 THEN 'BelowTarget'  
WHEN eqmttype = 'KOM930E' AND measureton BETWEEN 286 AND 315 THEN 'OnTarget'  
WHEN eqmttype = 'KOM930E' AND measureton BETWEEN 316 AND 330 THEN 'AboveTarget'  
WHEN eqmttype = 'KOM930E' AND measureton BETWEEN 331 AND 400 THEN 'OverLoaded'  
  
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
CASE WHEN Category = 'OverLoaded' THEN COUNT(ShovelId) 