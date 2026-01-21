CREATE VIEW [chi].[CONOPS_CHI_MATERIAL_DELIVERED_TO_CHRUSHER_V] AS




--select * from [chi].[CONOPS_CHI_MATERIAL_DELIVERED_TO_CHRUSHER_V] WITH (NOLOCK)
CREATE VIEW [chi].[CONOPS_CHI_MATERIAL_DELIVERED_TO_CHRUSHER_V] 
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
				COUNT(LfTons) AS NrDumps,
           		CASE
               		WHEN [Load] IN (4, 7, 10, 11, 12, 18)
                    	 AND loc = 'CRUSHER' THEN SUM(LfTons)
               		ELSE 0
           		END AS [TotalCrushedMillOre]
    	 FROM (
         	  SELECT enums.Idx AS [Load],
                	 dumps.shiftid,
					 dumps.siteflag,
                	 s.FieldId AS [ShovelId],
                	 (SELECT TOP 1 FieldId FROM chi.shift_loc WITH (NOLOCK) WHERE Id = dumps.FieldLoc) AS loc,
                	 dumps.FieldLsizedb AS [LfTons]
         	  FROM chi.shift_dump_v dumps WITH (NOLOCK)
         	  LEFT JOIN chi.shift_eqmt s WITH (NOLOCK)  ON s.Id = dumps.FieldExcav AND s.SHIFTID = dumps.shiftid
         	  LEFT JOIN chi.shift_load loads WITH (NOLOCK) ON dumps.[FieldLoadRec] = loads.[Id]
         	  LEFT JOIN chi.enum enums WITH (NOLOCK) ON enums.Id=dumps.FieldLoad
         	  WHERE enums.Idx NOT IN (2)
    	 ) AS Consolidated
		 WHERE loc = 'CRUSHER'
    	 GROUP BY Shiftid, [Load], [loc],siteflag
	) AS FINAL
	GROUP BY Shiftid, loc,siteflag
),

CrLocShift AS (
    SELECT a.siteflag,
           a.SHIFTFLAG,
           a.shiftid,
           a.SHIFTDURATION,
           'CRUSHER' AS CrusherLoc
    FROM [chi].[CONOPS_CHI_SHIFT_INFO_V] a WITH (NOLOCK)
)

SELECT cl.siteflag
      ,cl.SHIFTFLAG
      ,cl.CrusherLoc AS Name
      ,0 AS LeachActual
      ,0 AS LeachTarget
      ,0 AS LeachShiftTarget
      ,ROUND(SUM(COALESCE(TotalMaterialDeliveredtoCrusher, 0)) / 1000.00, 1) AS MillOreActual
      ,ROUND((COALESCE([ct].[Target], 0) * (FLOOR(cl.ShiftDuration / 3600) / 12.00 )) / 1000.00, 1) AS MillOreTarget
      ,ROUND(COALESCE([ct].[Target], 0) / 1000.00, 1) AS MillOreShiftTarget
	  ,COALESCE(NRDumps, 0) AS TotalNrDumps
FROM CrLocShift cl
LEFT JOIN CTE
ON cl.SITEFLAG = cte.siteflag AND cl.SHIFTID = cte.SHIFTID
   AND cl.CrusherLoc = cte.CrusherLoc
LEFT JOIN [chi].[CONOPS_CHI_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V] [ct] WITH (NOLOCK)
ON [ct].shiftid = cl.shiftid AND
   cl.CrusherLoc = [ct].[Location]
GROUP BY cl.siteflag, cl.SHIFTFLAG, cl.CrusherLoc, [ct].[Target], cl.ShiftDuration, NRDumps


