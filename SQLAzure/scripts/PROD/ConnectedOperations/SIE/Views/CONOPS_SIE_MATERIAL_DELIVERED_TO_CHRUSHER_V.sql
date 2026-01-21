CREATE VIEW [SIE].[CONOPS_SIE_MATERIAL_DELIVERED_TO_CHRUSHER_V] AS



--select * from [sie].[CONOPS_SIE_MATERIAL_DELIVERED_TO_CHRUSHER_V]
CREATE VIEW [sie].[CONOPS_SIE_MATERIAL_DELIVERED_TO_CHRUSHER_V] 
AS

WITH CTE AS (
SELECT  
shiftid,
siteflag,
CASE WHEN [loc] IN ('CR13909O', 'A-SIDE', 'B-SIDE') THEN 'Crusher' 
ELSE  NULL END
AS CrusherLoc,
[LfTons] AS TotalTons
FROM (
SELECT  
dumps.shiftid,
dumps.siteflag,
enums.Idx as [Load], 
loc.FieldId as loc,
dumps.FieldLsizetons AS [LfTons]
FROM [sie].SHIFT_DUMP_V dumps  WITH (NOLOCK)
LEFT JOIN [sie].Enum enums WITH (NOLOCK) on enums.Id=dumps.FieldLoad 
LEFT JOIN [sie].shift_loc loc WITH (NOLOCK) ON loc.Id = dumps.FieldLoc 
WHERE enums.Idx NOT IN (26,27,28,29,30)
AND (loc.FieldId IN ('CR13909O', 'A-SIDE', 'B-SIDE'))
) AS Consolidated 
),

CrLocShift AS (
SELECT 
a.siteflag,
a.SHIFTFLAG,
a.shiftid,
a.SHIFTDURATION,
'Crusher' AS CrusherLoc
FROM [sie].[CONOPS_SIE_SHIFT_INFO_V] a WITH (NOLOCK)
)

SELECT 
cl.siteflag
,cl.SHIFTFLAG
,cl.CrusherLoc AS Name
,0 AS LeachActual
,0 AS LeachTarget
,0 AS LeachShiftTarget
,ROUND(SUM(COALESCE(TotalTons, 0)) / 1000.00, 1) AS MillOreActual
,ROUND(MillOreTarget,1) AS MillOreTarget
,ROUND(MillOreShiftTarget,1) AS MillOreShiftTarget
,COUNT(TotalTons) AS TotalNrDumps
FROM CrLocShift cl
LEFT JOIN CTE
ON cl.SITEFLAG = cte.siteflag AND cl.SHIFTID = cte.SHIFTID
AND cl.CrusherLoc = cte.CrusherLoc
LEFT JOIN [sie].[CONOPS_SIE_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V] [ct] WITH (NOLOCK)
ON [ct].SHIFTFLAG = cl.SHIFTFLAG AND cl.CrusherLoc = [ct].[Location]
GROUP BY cl.siteflag, cl.SHIFTFLAG, cl.CrusherLoc, [ct].MillOreTarget, MillOreShiftTarget, TotalTons




