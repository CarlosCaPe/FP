CREATE VIEW [saf].[ZZZ_CONOPS_SAF_MATERIAL_DELIVERED_TO_CHRUSHER_V_BUP] AS





--select * from [saf].[CONOPS_SAF_MATERIAL_DELIVERED_TO_CHRUSHER_V]
CREATE VIEW [saf].[CONOPS_SAF_MATERIAL_DELIVERED_TO_CHRUSHER_V] 
AS

WITH CTE AS(
	SELECT dumps.SHIFTID,
		   dumps.siteflag,
		   l.FieldId AS CrusherLoc,
		   COUNT(dumps.[FieldTons]) AS NrDumps,
		   CASE WHEN l.FieldId LIKE '%crusher%' 
				THEN SUM(dumps.[FieldTons])
				ELSE 0
		   END AS TotalDeliveredToCrushers
	FROM (
	   SELECT SSD.[ShiftId],
			  SSD.siteflag,
			  SSD.[FieldLoc] AS [FieldLocD],
			  SSE.[FieldSize] AS FieldTons,
			  CASE
				  WHEN (r.FieldId = 'SAN JUAN'
						AND e.FieldId = 'S003')
					   OR (r.FieldId = 'SAN JUAN'
						   AND e.FieldId = 'S005') THEN 0
				  ELSE 1
			  END AS [IsValidShovelRegion]
	   FROM [saf].SHIFT_DUMP SSD  WITH (NOLOCK)
	   LEFT JOIN [saf].SHIFT_EQMT SSE  WITH (NOLOCK) ON SSE.Id = SSD.FieldTruck AND SSE.SHIFTID = SSD.SHIFTID
	   LEFT JOIN [saf].SHIFT_EQMT e  WITH (NOLOCK) ON e.Id = SSD.FieldExcav AND e.SHIFTID = SSD.SHIFTID
	   LEFT JOIN saf.shift_loc l WITH (NOLOCK) ON l.Id = SSD.FieldLoc
	   LEFT JOIN saf.shift_loc r WITH (NOLOCK) ON r.Id = l.FieldRegion
	) AS dumps
	LEFT JOIN saf.shift_loc l WITH (NOLOCK) ON dumps.FieldLocD = l.ID 
	WHERE dumps.IsValidShovelRegion = 1 AND l.FIELDID LIKE '%crusher%' 
	GROUP BY dumps.SHIFTID, l.FIELDID,dumps.siteflag
)

SELECT a.shiftid,
       a.siteflag,
	   a.shiftflag,
	   CrusherLoc,
	   0 AS MillOre,
	   COALESCE(TotalDeliveredToCrushers, 0) AS CrusherLeach,
	   NrDumps AS TotalNrDumps
FROM [saf].[CONOPS_SAF_SHIFT_INFO_V] a
LEFT JOIN CTE b ON a.shiftid = b.shiftid 

