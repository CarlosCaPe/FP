CREATE VIEW [CLI].[CONOPS_CLI_EQMT_TOTALMATERIALMINED_V] AS



CREATE VIEW [cli].[CONOPS_CLI_EQMT_TOTALMATERIALMINED_V]
AS


WITH CTE AS (
SELECT
shiftid,
shovelid,
TotalMaterialMined,
TotalMaterialMoved
FROM [cli].[CONOPS_CLI_SHIFT_OVERVIEW_V]
)

SELECT
siteflag,
a.shiftid,
shovelid,
TotalMaterialMined,
TotalMaterialMoved
FROM [cli].[CONOPS_CLI_SHIFT_INFO_V] a
LEFT JOIN CTE b on a.shiftid = b.shiftid
WHERE shovelid IS NOT NULL




