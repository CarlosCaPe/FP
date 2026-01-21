CREATE VIEW [sie].[crusher_stats_v] AS



--SELECT * FROM [sie].[crusher_stats_v] WITH (NOLOCK)  
CREATE VIEW [sie].[crusher_stats_v]     
AS        
  
	WITH CrLoc AS (
   		SELECT 'Crusher' CrusherLoc
   		UNION ALL
   		SELECT 'A-SIDE' CrusherLoc
   		UNION ALL
   		SELECT 'B-SIDE' CrusherLoc
	),

	CrLocShift AS (
   		SELECT a.SHIFTINDEX,
          	   a.SITEFLAG,
			   CrusherLoc
   		FROM CrLoc, [sie].[CONOPS_SIE_SHIFT_INFO_V] a WITH (NOLOCK)
		WHERE a.SHIFTFLAG = 'CURR'
	),

	WaitingForCrusher AS (
		SELECT t.siteflag,
			   t.SHIFTINDEX,
			   CASE WHEN [loc1].FieldId = 'CR13909O' THEN 'Crusher'
					ELSE [loc1].FieldId
			   END CrusherLoc,
			   COUNT(t.FieldId) NoOfTruckWaiting
		FROM [sie].[pit_truck_c] [t] WITH (NOLOCK)
		LEFT JOIN [sie].[pit_loc] [loc1] WITH (NOLOCK)
		ON [loc1].Id = [t].FieldLoc
		LEFT JOIN [sie].[pit_loc] [loc2] WITH (NOLOCK)
		ON [loc2].Id = t.FieldLocnext
		LEFT JOIN [sie].[CONOPS_SIE_SHIFT_INFO_V] s WITH (NOLOCK)
		ON s.SHIFTINDEX = t.SHIFTINDEX
		WHERE [loc1].FieldId IN ('CR13909O','A-SIDE','B-SIDE')
			  AND [loc2].FieldId IN ('CR13909O','A-SIDE','B-SIDE')
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
  

