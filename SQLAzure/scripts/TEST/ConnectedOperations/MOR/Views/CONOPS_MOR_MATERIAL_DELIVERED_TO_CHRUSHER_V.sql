CREATE VIEW [MOR].[CONOPS_MOR_MATERIAL_DELIVERED_TO_CHRUSHER_V] AS



--select * from [mor].[CONOPS_MOR_MATERIAL_DELIVERED_TO_CHRUSHER_V] WITH (NOLOCK)
CREATE VIEW [mor].[CONOPS_MOR_MATERIAL_DELIVERED_TO_CHRUSHER_V] 
AS

WITH CTE AS (
    SELECT shiftid,
		   siteflag,
		   CASE WHEN [loc] IN ( '849-MFL', 'C2MFL', 'C2MIL' ) THEN 'Crusher 2'
				WHEN [loc] IN ( '859-MILL', 'C3MFL', 'C3MIL' ) THEN 'Crusher 3'
				ELSE NULL
		   END AS CrusherLoc ,
		   CASE WHEN loc IN ( 'C2MIL', 'C3MIL' ) THEN SUM(LfTons)
				ELSE 0
		   END AS MillOreDeliveredToCrusher ,
		   CASE WHEN loc IN ( 'C2MFL', 'C3MFL' ) THEN SUM(LfTons)
		    	ELSE 0
		   END AS MflDeliveredToCrusher
	FROM (
			SELECT dumps.shiftid,
				   dumps.siteflag,
				   (SELECT TOP 1 FieldId FROM mor.shift_loc WITH (NOLOCK) WHERE     Id = dumps.FieldLoc) AS loc,
				   (SELECT TOP 1 COALESCE(SSE.[FieldSize], 0) FROM mor.shift_eqmt SSE WITH (NOLOCK)
						   WHERE SSE.Id = dumps.FieldTruck AND SSE.ShiftId = dumps.[OrigShiftid]
				   ) AS [LfTons]
			FROM mor.shift_dump_v dumps WITH (NOLOCK)
			LEFT JOIN mor.Enum (nolock) enums ON enums.Id = dumps.FieldLoad
			WHERE enums.Idx NOT IN ( 26, 27, 28, 29, 30 )
				  AND (
						SELECT TOP 1 FieldId FROM mor.shift_loc WITH (NOLOCK) WHERE Id = dumps.FieldLoc
				  ) IN ( 'C2MIL', 'C3MIL', 'C2MFL', 'C3MFL' )
					 
		 ) AS Consolidated
	GROUP BY loc, shiftid, siteflag
),

CrLoc AS (
    SELECT 'Crusher 2' CrusherLoc
	UNION ALL
	SELECT 'Crusher 3' CrusherLoc
),

CrLocShift AS (
    SELECT a.siteflag,
           a.SHIFTFLAG,
           a.shiftid,
           a.SHIFTDURATION,
           CrusherLoc
    FROM CrLoc, [mor].[CONOPS_MOR_SHIFT_INFO_V] a WITH (NOLOCK)
)

SELECT cl.siteflag
      ,cl.SHIFTFLAG
	  ,cl.SHIFTID
      ,cl.CrusherLoc AS Name
      ,ROUND(SUM(COALESCE(MflDeliveredToCrusher, 0)) / 1000.00, 1) AS LeachActual
      ,CASE WHEN cl.CrusherLoc = 'Crusher 2'
		    THEN ROUND((COALESCE([ct].[Target], 0) * (FLOOR(cl.ShiftDuration / 3600) / 12.00 )) / 1000.00, 1)
		    ELSE 0
       END AS LeachTarget
      ,CASE WHEN cl.CrusherLoc = 'Crusher 2'
		    THEN ROUND(COALESCE([ct].[Target], 0) / 1000.00, 1)
		    ELSE 0
       END AS LeachShiftTarget
      ,ROUND(SUM(COALESCE(MillOreDeliveredToCrusher, 0)) / 1000.00, 1) AS MillOreActual
      ,CASE WHEN cl.CrusherLoc = 'Crusher 3'
		    THEN ROUND((COALESCE([ct].[Target], 0) * (FLOOR(cl.ShiftDuration / 3600) / 12.00 )) / 1000.00, 1)
		    ELSE 0
       END AS MillOreTarget
      ,CASE WHEN cl.CrusherLoc = 'Crusher 3'
		    THEN ROUND(COALESCE([ct].[Target], 0) / 1000.00, 1)
		    ELSE 0
       END AS MillOreShiftTarget
FROM CrLocShift cl
LEFT JOIN CTE
ON cl.SITEFLAG = cte.siteflag AND cl.SHIFTID = cte.SHIFTID
   AND cl.CrusherLoc = cte.CrusherLoc
LEFT JOIN [mor].[CONOPS_MOR_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V] [ct] WITH (NOLOCK)
ON [ct].shiftid = cl.shiftid AND
   cl.CrusherLoc = [ct].[Location]
GROUP BY cl.siteflag, cl.SHIFTFLAG, cl.shiftid, cl.CrusherLoc, [ct].[Target], cl.ShiftDuration


