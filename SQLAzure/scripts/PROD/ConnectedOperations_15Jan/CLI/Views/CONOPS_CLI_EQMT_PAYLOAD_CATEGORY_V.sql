CREATE VIEW [CLI].[CONOPS_CLI_EQMT_PAYLOAD_CATEGORY_V] AS
  
  
-- SELECT * FROM [cli].[CONOPS_CLI_EQMT_PAYLOAD_CATEGORY_V] WHERE shiftindex = '38822'  
CREATE VIEW [cli].[CONOPS_CLI_EQMT_PAYLOAD_CATEGORY_V]  
AS  
  
WITH CTE AS (  
select  
t.SHIFTINDEX,  
t.fieldid as TruckId,  
REPLACE(enum.[description],' ','') as eqmttype,  
s.FieldId AS ShovelId,  
ld.measureton  
FROM [cli].[pit_truck_c] [t] WITH (NOLOCK)  
LEFT JOIN [cli].[pit_excav_c] [s] WITH (NOLOCK)  
ON [t].fieldexcav = [s].Id AND [t].SHIFTINDEX = [s].SHIFTINDEX  
LEFT JOIN dbo.LH_LOAD ld WITH (NOLOCK) ON t.SHIFTINDEX = ld.SHIFTINDEX AND s.FieldId = ld.excav AND ld.SITE_CODE = 'CLI'  
left join cli.enum enum WITH (NOLOCK)on enum.id = t.FieldEqmttype),  
  
CAT AS (  
SELECT  
shiftindex,  
ShovelId,  
CASE WHEN eqmttype = 'CAT789' AND measureton BETWEEN 90 AND 182 THEN 'UnderLoaded'  
WHEN eqmttype = 'CAT789' AND measureton BETWEEN 183 AND 186 THEN 'BelowTarget'  
WHEN eqmttype = 'CAT789' AND measureton BETWEEN 187 AND 195 THEN 'OnTarget'  
WHEN eqmttype = 'CAT789' AND measureton BETWEEN 196 AND 234 THEN 'AboveTarget'  
WHEN eqmttype = 'CAT789' AND measureton BETWEEN 235 AND 400 THEN 'OverLoaded'  
  
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
LEFT JOIN TOtalCat b ON a.SHIFTINDEX = b.SHIFTINDEX AND a.ShovelId = b.ShovelId  
GROUP BY   
a.shiftindex,  
a.ShovelId,  
b.CatTotal  
  
  
  
  
  
