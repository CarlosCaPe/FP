CREATE VIEW [TYR].[CONOPS_TYR_MATERIAL_DELIVERED_TO_CHRUSHER_V] AS




--select * from [tyr].[CONOPS_TYR_MATERIAL_DELIVERED_TO_CHRUSHER_V] WITH (NOLOCK)
CREATE VIEW [TYR].[CONOPS_TYR_MATERIAL_DELIVERED_TO_CHRUSHER_V] 
AS

WITH CTE AS (
    SELECT siteflag,
		   Shiftid, 
      	   loc AS CrusherLoc,
		   ISNULL(SUM(NrDumps), 0) AS NRDumps ,
      	   ISNULL(SUM(TotalCrushedMillOre), 0) AS TotalMaterialDeliveredtoCrusher
	FROM (
    	 SELECT [shiftid],
			    siteflag,
           		loc,
				COUNT(LfTons) AS NrDumps ,
           		CASE
               		WHEN [Load] IN (4, 7, 10, 11, 12, 18)
                    	 AND loc = 'CRUSHER 1' THEN SUM(LfTons)
               		ELSE 0
           		END AS [TotalCrushedMillOre]
    	 FROM (
         	  SELECT enums.Idx AS [Load],
                	 dumps.shiftid,
					 dumps.siteflag,
                	 s.FieldId AS [ShovelId],
                	 (SELECT TOP 1 FieldId FROM [tyr].shift_loc WITH (NOLOCK) WHERE Id = dumps.FieldLoc) AS loc,
                	 dumps.FieldLsizetons AS [LfTons]
         	  FROM [tyr].shift_dump_v dumps WITH (NOLOCK)
         	  LEFT JOIN [tyr].shift_eqmt s WITH (NOLOCK)  ON s.Id = dumps.FieldExcav AND s.SHIFTID = dumps.shiftid
         	  LEFT JOIN [tyr].shift_load loads WITH (NOLOCK) ON dumps.[FieldLoadRec] = loads.[Id]
         	  LEFT JOIN [tyr].enum enums WITH (NOLOCK) ON enums.Id=dumps.FieldLoad
         	  WHERE enums.Idx NOT IN (2)
    	 ) AS Consolidated
		 WHERE loc = 'CRUSHER 1'
    	 GROUP BY Shiftid, [Load], [loc],siteflag
	) AS FINAL
	GROUP BY Shiftid, loc,siteflag
),

CrLocShift AS (
    SELECT a.siteflag,
           a.SHIFTFLAG,
           a.shiftid,
           a.SHIFTDURATION,
           'CRUSHER 1' AS CrusherLoc
    FROM [tyr].[CONOPS_TYR_SHIFT_INFO_V] a WITH (NOLOCK)
)

SELECT cl.siteflag
      ,cl.SHIFTFLAG
	  ,cl.shiftid
      ,cl.CrusherLoc AS Name
      ,0 AS LeachActual
      ,0 AS LeachTarget
      ,0 AS LeachShiftTarget
      ,ROUND(SUM(COALESCE(TotalMaterialDeliveredtoCrusher, 0)) / 1000.00, 1) AS MillOreActual
      ,ROUND(COALESCE([ct].MillOreTarget,0) / 1000.00, 1) AS MillOreTarget
      ,ROUND(COALESCE([ct].MillOreShiftTarget, 0) / 1000.00, 1) AS MillOreShiftTarget
	  ,COALESCE(NRDumps, 0) AS TotalNrDumps
FROM CrLocShift cl
LEFT JOIN CTE
ON cl.SITEFLAG = cte.siteflag AND cl.SHIFTID = cte.SHIFTID
   AND cl.CrusherLoc = cte.CrusherLoc
LEFT JOIN [tyr].[CONOPS_TYR_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V] [ct] WITH (NOLOCK)
ON [ct].shiftflag = cl.shiftflag
GROUP BY cl.siteflag, cl.SHIFTFLAG, cl.CrusherLoc, cl.ShiftDuration, NRDumps ,cl.shiftid, [ct].MillOreShiftTarget, [ct].MillOreTarget


