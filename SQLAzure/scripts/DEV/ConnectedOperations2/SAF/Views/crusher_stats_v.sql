CREATE VIEW [SAF].[crusher_stats_v] AS




--SELECT * FROM [saf].[crusher_stats_v] WITH (NOLOCK)  
CREATE VIEW [saf].[crusher_stats_v]     
AS        
  
	WITH CrLocShift AS (
   		SELECT a.SHIFTINDEX,
          	   a.SITEFLAG,
			   'CRUSHER' AS CrusherLoc
   		FROM [saf].[CONOPS_SAF_SHIFT_INFO_V] a WITH (NOLOCK)
		WHERE a.SHIFTFLAG = 'CURR'
	),

	WaitingForCrusher AS (
		SELECT t.siteflag,
			   t.SHIFTINDEX,
			   'CRUSHER' CrusherLoc,
			   COUNT(t.FieldId) NoOfTruckWaiting
		FROM [saf].[pit_truck_c] [t] WITH (NOLOCK)
		LEFT JOIN [saf].[pit_loc] [loc] WITH (NOLOCK)
		ON [loc].Id = [t].FieldLoc
		LEFT JOIN [saf].[pit_loc] [nloc] WITH (NOLOCK)
		ON [nloc].Id = [t].FieldLocnext
		WHERE UPPER([loc].[FieldId]) = 'CRUSHER'
			  AND UPPER([nloc].[FieldId]) = 'CRUSHER'
		GROUP BY t.siteflag, t.SHIFTINDEX
	)

	SELECT cl.siteflag,
		   cl.SHIFTINDEX,
		   cl.CrusherLoc,
		   ISNULL(wc.NoOfTruckWaiting, 0) NoOfTruckWaiting,
		   FORMAT(GETUTCDATE(), 'yyyy-MM-dd HH:mm:00') GeneratedUTCDate
	FROM CrLocShift cl
	LEFT JOIN WaitingForCrusher wc
	ON cl.SHIFTINDEX = wc.SHIFTINDEX
		  AND cl.CrusherLoc = wc.CrusherLoc
  


