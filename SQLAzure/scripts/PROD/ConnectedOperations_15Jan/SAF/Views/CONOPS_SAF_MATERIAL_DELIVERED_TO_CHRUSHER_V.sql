CREATE VIEW [SAF].[CONOPS_SAF_MATERIAL_DELIVERED_TO_CHRUSHER_V] AS


--select * from [saf].[CONOPS_SAF_MATERIAL_DELIVERED_TO_CHRUSHER_V]
CREATE VIEW [saf].[CONOPS_SAF_MATERIAL_DELIVERED_TO_CHRUSHER_V] 
AS

	WITH CTE AS (
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
		GROUP BY dumps.SHIFTID, l.FIELDID, dumps.siteflag
	),

	CrLocShift AS (
   		SELECT a.siteflag,
          	   a.SHIFTFLAG,
          	   a.shiftid,
          	   a.SHIFTDURATION,
          	   'CRUSHER' AS CrusherLoc
   		FROM [saf].[CONOPS_SAF_SHIFT_INFO_V] a WITH (NOLOCK)
	)

	SELECT cl.siteflag
     	  ,SHIFTFLAG
     	  ,cl.CrusherLoc AS Name
     	  ,ROUND(SUM(COALESCE(TotalDeliveredToCrushers, 0)) / 1000.00, 1) AS LeachActual
     	  ,ROUND((COALESCE([ct].[Target], 0) * (FLOOR(cl.ShiftDuration / 3600) / 12.00 )) / 1000.00, 1) AS LeachTarget
     	  ,ROUND(COALESCE([ct].[Target], 0) / 1000.00, 1) AS LeachShiftTarget
     	  ,0 AS MillOreActual
     	  ,0 AS MillOreTarget
     	  ,0 AS MillOreShiftTarget
		  ,NrDumps AS TotalNrDumps
	FROM CrLocShift cl
	LEFT JOIN CTE
	ON cl.SITEFLAG = cte.siteflag AND cl.SHIFTID = cte.SHIFTID
  	   AND cl.CrusherLoc = cte.CrusherLoc
	LEFT JOIN [saf].[CONOPS_SAF_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V] [ct] WITH (NOLOCK)
	ON [ct].shiftid = cl.shiftid AND
  	   cl.CrusherLoc = [ct].[Location]
	GROUP BY cl.siteflag, SHIFTFLAG, cl.CrusherLoc, [ct].[Target], cl.ShiftDuration, NrDumps


