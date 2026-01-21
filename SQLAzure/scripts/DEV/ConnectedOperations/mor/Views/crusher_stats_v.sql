CREATE VIEW [mor].[crusher_stats_v] AS



--SELECT * FROM [mor].[crusher_stats_v] WITH (NOLOCK)  
CREATE VIEW [mor].[crusher_stats_v]     
AS        
  
	WITH CrLoc AS (
   		SELECT 'Crusher 2' CrusherLoc
   		UNION ALL
   		SELECT 'Crusher 3' CrusherLoc
	),

	CrLocShift AS (
   		SELECT a.SHIFTINDEX,
          	   a.SITEFLAG,
			   CrusherLoc
   		FROM CrLoc, [mor].[CONOPS_MOR_SHIFT_INFO_V] a WITH (NOLOCK)
		WHERE a.SHIFTFLAG = 'CURR'
	),

	WaitingForCrusher AS (
		SELECT t.siteflag,
			   t.SHIFTINDEX,
			   CASE WHEN [loc1].FieldId IN ('C2MIL', 'C2MFL', '849-MFL') THEN 'Crusher 2'
					WHEN [loc1].FieldId IN ('C3MIL', 'C3MFL', '859-MILL') THEN 'Crusher 3'
			   END CrusherLoc,
			   COUNT(t.FieldId) NoOfTruckWaiting
		FROM [mor].[pit_truck_c] [t] WITH (NOLOCK)
		LEFT JOIN [mor].[pit_loc] [loc1] WITH (NOLOCK)
		ON [loc1].Id = [t].FieldLoc
		LEFT JOIN [mor].[pit_loc] [loc2] WITH (NOLOCK)
		ON [loc2].Id = t.FieldLocnext
		LEFT JOIN [mor].[CONOPS_MOR_SHIFT_INFO_V] s WITH (NOLOCK)
		ON s.SHIFTINDEX = t.SHIFTINDEX
		WHERE [loc1].FieldId IN ('C2MIL','C2MFL','849-MFL', 'C3MIL','C3MFL','859-MILL')
			  AND [loc2].FieldId IN ('C2MIL','C2MFL','849-MFL', 'C3MIL','C3MFL','859-MILL')
			  AND s.SHIFTFLAG = 'CURR'
		GROUP BY t.siteflag, t.SHIFTINDEX, [loc1].FieldId
	)

	SELECT cl.siteflag,
		   cl.SHIFTINDEX,
		   cl.CrusherLoc,
		   ISNULL(SUM(wc.NoOfTruckWaiting), 0) NoOfTruckWaiting,
		   FORMAT(GETUTCDATE(), 'yyyy-MM-dd HH:mm:00') GeneratedUTCDate
	FROM CrLocShift cl
	LEFT JOIN WaitingForCrusher wc
	ON cl.SHIFTINDEX = wc.SHIFTINDEX
		  AND cl.CrusherLoc = wc.CrusherLoc
	GROUP BY cl.siteflag, cl.SHIFTINDEX, cl.CrusherLoc
  

