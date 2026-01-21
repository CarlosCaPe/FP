CREATE VIEW [TYR].[CONOPS_TYR_EQMT_TOTALMATERIALMINED_V] AS





CREATE VIEW [TYR].[CONOPS_TYR_EQMT_TOTALMATERIALMINED_V]
AS


WITH CTE AS (
SELECT
shiftid,
shovelid,
TotalMaterialMined,
TotalMaterialMoved
FROM [tyr].[CONOPS_TYR_SHIFT_OVERVIEW_V]
)

SELECT
siteflag,
a.shiftid,
shovelid,
TotalMaterialMined,
TotalMaterialMoved
FROM [tyr].[CONOPS_TYR_SHIFT_INFO_V] a
LEFT JOIN CTE b on a.shiftid = b.shiftid
WHERE shovelid IS NOT NULL





