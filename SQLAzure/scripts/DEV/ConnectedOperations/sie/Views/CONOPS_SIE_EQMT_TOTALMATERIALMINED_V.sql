CREATE VIEW [sie].[CONOPS_SIE_EQMT_TOTALMATERIALMINED_V] AS


CREATE VIEW [sie].[CONOPS_SIE_EQMT_TOTALMATERIALMINED_V]
AS


WITH CTE AS (
SELECT
shiftid,
shovelid,
ROUND(SUM(TotalMaterialMoved),0) AS TotalMaterialMined,
ROUND(SUM(TotalMineralsMined),0) AS TotalMaterialMoved
FROM [sie].[CONOPS_SIE_SHIFT_OVERVIEW_V] 
GROUP BY shiftid, shovelid
)

SELECT
siteflag,
a.shiftid,
shovelid,
TotalMaterialMined,
TotalMaterialMoved
FROM [sie].[CONOPS_SIE_SHIFT_INFO_V] a
LEFT JOIN CTE b on a.shiftid = b.shiftid
WHERE shovelid IS NOT NULL




