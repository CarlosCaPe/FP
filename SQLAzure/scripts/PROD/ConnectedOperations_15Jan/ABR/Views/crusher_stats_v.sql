CREATE VIEW [ABR].[crusher_stats_v] AS






--SELECT * FROM [abr].[crusher_stats_v] WITH (NOLOCK)  
CREATE VIEW [abr].[crusher_stats_v]     
AS
  
WITH CrLoc AS (
   	SELECT 'Crusher 1' CrusherLoc
),

CrLocShift AS (
   	SELECT a.SHIFTINDEX,
         	   a.SITEFLAG,
		   CrusherLoc
   	FROM CrLoc, [abr].[CONOPS_abr_SHIFT_INFO_V] a WITH (NOLOCK)
	WHERE a.SHIFTFLAG = 'CURR'
),

WaitingForCrusher AS (
	SELECT t.siteflag,
		   t.SHIFTINDEX,
		   CASE WHEN [loc1].FieldId IN ('C.1') THEN 'Crusher 1'
		   END CrusherLoc,
		   COUNT(t.FieldId) NoOfTruckWaiting
	FROM [abr].[pit_truck_c] [t] WITH (NOLOCK)
	LEFT JOIN [abr].[pit_loc] [loc1] WITH (NOLOCK)
	ON [loc1].Id = [t].FieldLoc
	LEFT JOIN [abr].[pit_loc] [loc2] WITH (NOLOCK)
	ON [loc2].Id = t.FieldLocnext
	LEFT JOIN [abr].[CONOPS_abr_SHIFT_INFO_V] s WITH (NOLOCK)
	ON s.SHIFTINDEX = t.SHIFTINDEX
	WHERE s.SHIFTFLAG = 'CURR'
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
  




