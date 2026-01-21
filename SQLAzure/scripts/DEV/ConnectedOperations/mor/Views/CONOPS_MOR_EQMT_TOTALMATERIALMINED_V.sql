CREATE VIEW [mor].[CONOPS_MOR_EQMT_TOTALMATERIALMINED_V] AS


CREATE VIEW [mor].[CONOPS_MOR_EQMT_TOTALMATERIALMINED_V]
AS


WITH CTE AS (
SELECT
shiftid,
shovelid,
TotalMaterialMined,
TotalMineralsMined AS TotalMaterialMoved
FROM [mor].[CONOPS_MOR_SHIFT_OVERVIEW_V]
)

SELECT
siteflag,
a.shiftid,
shovelid,
TotalMaterialMined,
TotalMaterialMoved
FROM [mor].[CONOPS_MOR_SHIFT_INFO_V] a
LEFT JOIN CTE b on a.shiftid = b.shiftid
WHERE shovelid IS NOT NULL




