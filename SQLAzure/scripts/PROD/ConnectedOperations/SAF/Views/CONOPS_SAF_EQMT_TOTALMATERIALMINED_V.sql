CREATE VIEW [SAF].[CONOPS_SAF_EQMT_TOTALMATERIALMINED_V] AS


CREATE VIEW [saf].[CONOPS_SAF_EQMT_TOTALMATERIALMINED_V]
AS


WITH CTE AS (
SELECT
shiftid,
shovelid,
TotalMineralsMined AS TotalMaterialMined,
TotalMaterialMined AS TotalMaterialMoved
FROM [saf].[CONOPS_SAF_SHIFT_OVERVIEW_V]
)

SELECT
siteflag,
a.shiftid,
shovelid,
TotalMaterialMined,
TotalMaterialMoved
FROM [saf].[CONOPS_SAF_SHIFT_INFO_V] a
LEFT JOIN CTE b on a.shiftid = b.shiftid
WHERE shovelid IS NOT NULL




