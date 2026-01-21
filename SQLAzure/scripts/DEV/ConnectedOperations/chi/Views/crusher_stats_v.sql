CREATE VIEW [chi].[crusher_stats_v] AS



--SELECT * FROM [chi].[crusher_stats_v] WITH (NOLOCK)  
CREATE VIEW [chi].[crusher_stats_v]     
AS        
  
	WITH CrLocShift AS (
   		SELECT a.SHIFTINDEX,
          	   a.SITEFLAG,
			   'CRUSHER' AS CrusherLoc
   		FROM [chi].[CONOPS_CHI_SHIFT_INFO_V] a WITH (NOLOCK)
		WHERE a.SHIFTFLAG = 'CURR'
	),

	WaitingForCrusher AS (
		SELECT t.siteflag,
			   t.SHIFTINDEX,
			   'CRUSHER' CrusherLoc,
			   COUNT(t.FieldId) NoOfTruckWaiting
		FROM [chi].[pit_truck_c] [t] WITH (NOLOCK)
		LEFT JOIN [chi].[pit_loc] [loc] WITH (NOLOCK)
		ON [loc].Id = [t].FieldLoc
		LEFT JOIN [chi].[pit_loc] [nloc] WITH (NOLOCK)
		ON [nloc].Id = [t].FieldLocnext
		WHERE [loc].[FieldId] = 'CRUSHER'
			  AND [nloc].[FieldId] = 'CRUSHER'
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
  

