CREATE VIEW [cer].[ZZZ_CONOPS_CER_MATERIAL_DELIVERED_TO_CHRUSHER_V_OLD] AS




--select * from [cer].[CONOPS_CER_MATERIAL_DELIVERED_TO_CHRUSHER_V] WITH (NOLOCK) where shiftflag = 'prev'
CREATE VIEW [cer].[CONOPS_CER_MATERIAL_DELIVERED_TO_CHRUSHER_V_OLD]
AS

WITH CTE AS (
	SELECT shiftid,
		   siteflag,
		   [loc] AS CrusherLoc,
		   SUM(CASE WHEN loc in ('MILLCHAN', 'HIDRO-C1', 'MILLCRUSH1', 'MILLCRUSH2')
					THEN lfTons
					ELSE 0
			   END) AS MillOre,
		   SUM(CASE WHEN loc in ('HIDROCHAN')
					THEN lfTons
					ELSE 0
			   END) AS CrusherLeach,
		   COUNT(lfTons) AS TotalNrDumps
	FROM (
		  SELECT IIF(locs.FieldId = 'HIDRO-C1', 'MILLCHAN', locs.FieldId) AS loc,
				 dumps.FieldLSizeTons AS [LfTons],
				 dumps.ShiftId,
				 dumps.siteflag
		  FROM [cer].SHIFT_DUMP_V dumps WITH (NOLOCK)
		  LEFT JOIN CER.shift_loc locs WITH(NOLOCK) ON locs.ShiftId=dumps.ShiftId
		  AND locs.shift_loc_id =dumps.FieldLoc
		  WHERE locs.FieldId in ('MILLCHAN', 'HIDRO-C1', 'MILLCRUSH1',
								 'MILLCRUSH2', 'HIDROCHAN')
	) AS Consolidated
	GROUP BY shiftid, loc, siteflag
),

CrLoc AS (
    SELECT 'MILLCHAN' CrusherLoc
    UNION ALL
    SELECT 'HIDRO-C1' CrusherLoc
    UNION ALL
    SELECT 'MILLCRUSH1' CrusherLoc
    UNION ALL
    SELECT 'MILLCRUSH2' CrusherLoc
    UNION ALL
    SELECT 'HIDROCHAN' CrusherLoc
),

CrLocShift AS (
    SELECT a.siteflag,
           a.SHIFTFLAG,
           a.shiftid,
           a.SHIFTDURATION,
           CrusherLoc
    FROM CrLoc, [cer].[CONOPS_CER_SHIFT_INFO_V] a WITH (NOLOCK)
)

SELECT cl.siteflag
      ,cl.SHIFTFLAG
      ,cl.CrusherLoc AS Name
      ,ROUND(SUM(COALESCE(CrusherLeach, 0)) / 1000.00, 1) AS LeachActual
	  ,CASE WHEN cl.CrusherLoc = 'HIDROCHAN'
		    THEN ROUND((COALESCE([ct].[Target], 0) * (FLOOR(cl.ShiftDuration / 3600) / 12.00 )) / 1000.00, 1)
		    ELSE 0
       END AS LeachTarget
      ,CASE WHEN cl.CrusherLoc = 'HIDROCHAN'
		    THEN ROUND(COALESCE([ct].[Target], 0) / 1000.00, 1)
		    ELSE 0
       END AS LeachShiftTarget
      ,ROUND(SUM(COALESCE(MillOre, 0)) / 1000.00, 1) AS MillOreActual
      ,CASE WHEN cl.CrusherLoc <> 'HIDROCHAN'
		    THEN ROUND((COALESCE([ct].[Target], 0) * (FLOOR(cl.ShiftDuration / 3600) / 12.00 )) / 1000.00, 1)
		    ELSE 0
       END AS MillOreTarget
      ,CASE WHEN cl.CrusherLoc <> 'HIDROCHAN'
		    THEN ROUND(COALESCE([ct].[Target], 0) / 1000.00, 1)
		    ELSE 0
       END AS MillOreShiftTarget
	  ,TotalNrDumps
FROM CrLocShift cl
LEFT JOIN CTE
ON cl.SITEFLAG = cte.siteflag AND cl.SHIFTID = cte.SHIFTID
   AND cl.CrusherLoc = cte.CrusherLoc
LEFT JOIN [cer].[CONOPS_CER_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V] [ct] WITH (NOLOCK)
ON [ct].shiftid = cl.shiftid AND
   cl.CrusherLoc = [ct].[Location]
GROUP BY cl.siteflag, cl.SHIFTFLAG, cl.CrusherLoc, [ct].[Target], cl.ShiftDuration, TotalNrDumps

