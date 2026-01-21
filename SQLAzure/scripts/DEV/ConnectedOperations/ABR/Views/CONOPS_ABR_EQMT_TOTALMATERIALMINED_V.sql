CREATE VIEW [ABR].[CONOPS_ABR_EQMT_TOTALMATERIALMINED_V] AS



CREATE VIEW [abr].[CONOPS_ABR_EQMT_TOTALMATERIALMINED_V]
AS


WITH CTE AS (
SELECT
shiftid,
shovelid,
TotalMaterialMined,
TotalMaterialMoved
FROM [abr].[CONOPS_ABR_SHIFT_OVERVIEW_V]
)

SELECT
siteflag,
a.shiftid,
shovelid,
TotalMaterialMined,
TotalMaterialMoved
FROM [abr].[CONOPS_ABR_SHIFT_INFO_V] a
LEFT JOIN CTE b on a.shiftid = b.shiftid
WHERE shovelid IS NOT NULL




