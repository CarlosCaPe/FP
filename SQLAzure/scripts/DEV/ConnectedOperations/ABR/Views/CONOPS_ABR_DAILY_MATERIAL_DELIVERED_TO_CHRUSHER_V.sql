CREATE VIEW [ABR].[CONOPS_ABR_DAILY_MATERIAL_DELIVERED_TO_CHRUSHER_V] AS





--select * from [abr].[CONOPS_ABR_DAILY_MATERIAL_DELIVERED_TO_CHRUSHER_V] WITH (NOLOCK)
CREATE VIEW [ABR].[CONOPS_ABR_DAILY_MATERIAL_DELIVERED_TO_CHRUSHER_V] 
AS


WITH CTE AS (
SELECT 
dumps.shiftid,
s.FieldId AS [ShovelId],
(SELECT TOP 1 FieldId FROM [abr].shift_loc WITH (NOLOCK) WHERE Id = dumps.FieldLoc) AS loc,
dumps.FieldLsizetons AS [LfTons],
enums.Idx AS [Load],
enums.[DESCRIPTION]
FROM [abr].shift_dump_v dumps WITH (NOLOCK)
LEFT JOIN [abr].shift_eqmt s WITH (NOLOCK)  ON s.Id = dumps.FieldExcav AND s.SHIFTID = dumps.shiftid
LEFT JOIN [abr].shift_load loads WITH (NOLOCK) ON dumps.[FieldLoadRec] = loads.[Id]
LEFT JOIN [abr].enum enums WITH (NOLOCK) ON enums.Id=dumps.FieldLoad
),

CrusherLoad AS (
SELECT
shiftid,
ShovelId,
CASE WHEN Loc = 'C.1' THEN 'Crusher 1' END AS CrusherLoc,
COUNT(LfTons) AS NrDumps,
CASE WHEN [Load] = 8 THEN SUM(LfTons) ELSE 0 END AS MillOre,
CASE WHEN [Load] = 7 THEN SUM(LfTons) ELSE 0 END AS Leach
FROM CTE
WHERE Loc = 'C.1'
GROUP BY shiftid,ShovelId,Loc,[Load]
)

SELECT
a.siteflag,
a.shiftflag,
a.shiftid,
a.shiftindex,
CrusherLoc AS [Name],
ROUND(SUM(COALESCE(Leach, 0)) / 1000.00, 1) As LeachActual,
--,ROUND((COALESCE([ct].[Target], 0) * (FLOOR(cl.ShiftDuration / 3600) / 12.00 )) / 1000.00, 1) AS MillOreTarget,
0 LeachTarget,
--ROUND(COALESCE([ct].[Target], 0) / 1000.00, 1) AS MillOreShiftTarget,
0 LeachShiftTarget,
ROUND(SUM(COALESCE(MillOre, 0)) / 1000.00, 1) As MillOreActual,
--,ROUND((COALESCE([ct].[Target], 0) * (FLOOR(cl.ShiftDuration / 3600) / 12.00 )) / 1000.00, 1) AS MillOreTarget,
0 MillOreTarget,
--ROUND(COALESCE([ct].[Target], 0) / 1000.00, 1) AS MillOreShiftTarget,
0 MillOreShiftTarget,
COALESCE(NRDumps, 0) AS TotalNrDumps
FROM [abr].[CONOPS_ABR_EOS_SHIFT_INFO_V] a
LEFT JOIN CrusherLoad b
ON a.shiftid = b.shiftid
GROUP BY 
a.siteflag,
a.shiftflag,
a.shiftid,
a.shiftindex,
CrusherLoc,
NRDumps




