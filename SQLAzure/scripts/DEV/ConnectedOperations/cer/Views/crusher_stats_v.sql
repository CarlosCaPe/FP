CREATE VIEW [cer].[crusher_stats_v] AS



--SELECT * FROM [cer].[crusher_stats_v] WITH (NOLOCK)  
CREATE VIEW [cer].[crusher_stats_v]     
AS        
  
	WITH CrLoc AS (
   		SELECT 'MILLCHAN' CrusherLoc
   		UNION ALL
   		SELECT 'MILLCRUSH1' CrusherLoc
   		UNION ALL
   		SELECT 'MILLCRUSH2' CrusherLoc
   		UNION ALL
   		SELECT 'HIDROCHAN' CrusherLoc
	),

	CrLocShift AS (
   		SELECT a.SHIFTINDEX,
          	   a.SITEFLAG,
			   CrusherLoc
   		FROM CrLoc, [cer].[CONOPS_CER_SHIFT_INFO_V] a WITH (NOLOCK)
		WHERE a.SHIFTFLAG = 'CURR'
	),

	WaitingForCrusher AS (
		SELECT t.siteflag,
			   t.SHIFTINDEX,
			   [loc1].FieldId CrusherLoc,
			   COUNT(t.FieldId) NoOfTruckWaiting
		FROM [cer].[pit_truck_c] [t] WITH (NOLOCK)
		LEFT JOIN [cer].[pit_loc] [loc1] WITH (NOLOCK)
		ON [loc1].Id = [t].FieldLoc
		LEFT JOIN [cer].[pit_loc] [loc2] WITH (NOLOCK)
		ON [loc2].Id = t.FieldLocnext
		LEFT JOIN [cer].[CONOPS_CER_SHIFT_INFO_V] s WITH (NOLOCK)
		ON s.SHIFTINDEX = t.SHIFTINDEX
		WHERE [loc1].FieldId in ('MILLCHAN','MILLCRUSH1','MILLCRUSH2', 'HIDROCHAN')
			  AND [loc2].FieldId in ('MILLCHAN','MILLCRUSH1','MILLCRUSH2', 'HIDROCHAN')
			  AND s.SHIFTFLAG = 'CURR'
		GROUP BY t.siteflag, t.SHIFTINDEX, [loc1].FieldId
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
  

