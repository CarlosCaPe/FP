CREATE VIEW [CHI].[CONOPS_CHI_EQMT_TOTALMATERIALMINED_V] AS


CREATE VIEW [chi].[CONOPS_CHI_EQMT_TOTALMATERIALMINED_V]
AS


WITH CTE AS (
SELECT
shiftid,
shovelid,
TotalMaterialMined,
TotalMaterialMoved
FROM [chi].[CONOPS_CHI_SHIFT_OVERVIEW_V]
)

SELECT
siteflag,
a.shiftid,
shovelid,
TotalMaterialMined,
TotalMaterialMoved
FROM [chi].[CONOPS_CHI_SHIFT_INFO_V] a
LEFT JOIN CTE b on a.shiftid = b.shiftid
WHERE shovelid IS NOT NULL




