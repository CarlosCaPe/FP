CREATE VIEW [CLI].[CONOPS_CLI_MATERIAL_DELIVERED_TO_CHRUSHER_V] AS




--select * from [cli].[CONOPS_CLI_MATERIAL_DELIVERED_TO_CHRUSHER_V] WITH (NOLOCK)
CREATE VIEW [cli].[CONOPS_CLI_MATERIAL_DELIVERED_TO_CHRUSHER_V] 
AS

WITH CTE AS (
SELECT  shiftid,
			siteflag,
			CASE WHEN [loc] IN ('CRUSHER 1') THEN 'Crusher 1' 
			ELSE  NULL END
			AS CrusherLoc,
			[LfTons] AS TotalTons
	FROM 
		(
			SELECT  dumps.shiftid,
					dumps.siteflag,
					enums.Idx as [Load], 
					loc.FieldId as loc,
					--dumps.FieldLsizetons AS [LfTons]
					dumps.FIELDLSIZEDB AS [LfTons]
			FROM [cli].SHIFT_DUMP dumps  WITH (NOLOCK)
			LEFT JOIN [cli].Enum enums WITH (NOLOCK) on enums.Id=dumps.FieldLoad 
			LEFT JOIN [cli].shift_loc loc WITH (NOLOCK) ON loc.Id = dumps.FieldLoc 
			WHERE enums.Idx NOT IN (26,27,28,29,30)
			AND (loc.FieldId IN ('CRUSHER 1'))
		) AS Consolidated 
),

CrLocShift AS (
SELECT a.siteflag,
a.SHIFTFLAG,
a.shiftid,
a.SHIFTDURATION,
'CRUSHER 1' AS CrusherLoc
FROM [cli].[CONOPS_CLI_SHIFT_INFO_V] a WITH (NOLOCK)
)

SELECT cl.siteflag
,cl.SHIFTFLAG
,cl.shiftid
,cl.CrusherLoc AS Name
,0 AS LeachActual
,0 AS LeachTarget
,0 AS LeachShiftTarget
,ROUND(SUM(COALESCE(TotalTons, 0)) / 1000.00, 1) AS MillOreActual
,ROUND((COALESCE([ct].[Target], 0) * (FLOOR(cl.ShiftDuration / 3600) / 12.00 )) / 1000.00, 1) AS MillOreTarget
,ROUND(COALESCE([ct].[Target], 0) / 1000.00, 1) AS MillOreShiftTarget
,COUNT(TotalTons) AS TotalNrDumps
FROM CrLocShift cl
LEFT JOIN CTE
ON cl.SITEFLAG = cte.siteflag AND cl.SHIFTID = cte.SHIFTID
AND cl.CrusherLoc = cte.CrusherLoc
LEFT JOIN [cli].[CONOPS_CLI_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V] [ct] WITH (NOLOCK)
ON [ct].shiftid = cl.shiftid AND
cl.CrusherLoc = [ct].[Location]
GROUP BY cl.siteflag, cl.SHIFTFLAG, cl.CrusherLoc, [ct].[Target], cl.ShiftDuration ,cl.shiftid



