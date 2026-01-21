CREATE VIEW [chi].[ZZZ_CONOPS_CHI_MATERIAL_DELIVERED_TO_CHRUSHER_V_BUP] AS




--select * from [chi].[CONOPS_CHI_MATERIAL_DELIVERED_TO_CHRUSHER_V]
CREATE VIEW [chi].[CONOPS_CHI_MATERIAL_DELIVERED_TO_CHRUSHER_V] 
AS

WITH CTE AS(
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
               		WHEN [Load] IN (4, 7, 10, 11, 12)
                    	 AND loc = 'CRUSHER' THEN SUM(LfTons)
               		ELSE 0
           		END AS [TotalCrushedMillOre]
    	 FROM (
         	  SELECT enums.Idx AS [Load],
                	 dumps.shiftid,
					 dumps.siteflag,
                	 s.FieldId AS [ShovelId],
                	 (SELECT TOP 1 FieldId FROM chi.shift_loc WITH (NOLOCK) WHERE Id = dumps.FieldLoc) AS loc,
                	 dumps.FieldLsizetons AS [LfTons]
         	  FROM chi.shift_dump_v dumps WITH (NOLOCK)
         	  LEFT JOIN chi.shift_eqmt s WITH (NOLOCK)  ON s.Id = dumps.FieldExcav AND s.SHIFTID = dumps.shiftid
         	  LEFT JOIN chi.shift_load loads WITH (NOLOCK) ON dumps.[FieldLoadRec] = loads.[Id]
         	  LEFT JOIN chi.enum enums WITH (NOLOCK) ON enums.Id=dumps.FieldLoad
         	  WHERE enums.Idx NOT IN (2)
    	 ) AS Consolidated
		 WHERE loc = 'CRUSHER'
    	 GROUP BY Shiftid, [Load], [loc],siteflag
	) AS FINAL
	GROUP BY Shiftid, loc,siteflag
)

SELECT a.shiftid,
	   a.siteflag,
	   a.shiftflag,
		CrusherLoc,
		COALESCE(TotalMaterialDeliveredtoCrusher, 0) AS MillOre,
		0 AS CrusherLeach,
		NrDumps AS TotalNrDumps
FROM [chi].[CONOPS_CHI_SHIFT_INFO_V] a
LEFT JOIN CTE b ON a.shiftid = b.shiftid 

