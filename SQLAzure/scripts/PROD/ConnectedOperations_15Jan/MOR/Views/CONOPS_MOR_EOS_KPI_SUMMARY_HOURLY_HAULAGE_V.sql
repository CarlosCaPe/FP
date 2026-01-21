CREATE VIEW [MOR].[CONOPS_MOR_EOS_KPI_SUMMARY_HOURLY_HAULAGE_V] AS





-- SELECT * FROM [mor].[CONOPS_MOR_EOS_KPI_SUMMARY_HOURLY_HAULAGE_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [mor].[CONOPS_MOR_EOS_KPI_SUMMARY_HOURLY_HAULAGE_V]  
AS  
  
	WITH RawEFH AS (
		SELECT siteflag
			  ,shiftid
			  ,ShiftStartDateTime
			  ,CurrentTime
			  ,IIF(HOS > 11, 11, HOS) HOS
			  ,EFH
		FROM (
			SELECT siteflag
				  ,shiftid
				  ,ShiftStartDateTime
				  ,CurrentTime
				  ,FLOOR(DATEDIFF(MINUTE, ShiftStartDateTime, CurrentTime) / 60.00) as HOS
				  ,EFH
			FROM [dbo].[EFH_SNAPSHOT_SEQ] snapseq WITH (NOLOCK) 
			WHERE siteflag = 'MOR'
		) main
	),

	TonnageRaw AS (
		SELECT Siteflag,
			   shiftflag,
			   shiftid,
			   actual,
			   IIF(HOS > 11, 11, HOS) HOS,
			   ShiftStartDateTime,
			   ShiftEndDateTime,
			   ROW_NUMBER() OVER (PARTITION BY shiftflag, IIF(HOS > 11, 11, HOS) ORDER BY [DateTime] DESC) AS rn
		FROM (
			SELECT Siteflag,
				   shiftflag,
				   shiftid,
				   actual,
				   FLOOR(DATEDIFF(MINUTE, ShiftStartDateTime, [DateTime]) / 60.00) as HOS,
				   [DateTime],
				   ShiftStartDateTime,
				   ShiftEndDateTime
			FROM [mor].[CONOPS_MOR_SHIFT_LINE_GRAPH_V] (NOLOCK)
		) m
	),

	EFHTarget AS (
		SELECT ShiftId as shiftdate,
			   EFHShiftTarget as EFHShifttarget
		FROM [mor].[CONOPS_MOR_SHIFT_TARGET_V] WITH (NOLOCK)
	),

	TotalTarget AS (
		SELECT Shiftid,
			   ShiftTarget as shifttarget
		FROM  [mor].[CONOPS_MOR_SHIFT_TARGET_V] WITH (NOLOCK)
	),

	EFH AS (
		SELECT a.SITEFLAG
			  ,a.SHIFTFLAG
			  ,a.ShiftStartDateTime
			  ,HOS
			  ,ISNULL(AVG(EFH), 0) EFH
			  --,((HOS + 1)/12) * t.EFHShifttarget EFHTarget
			  ,t.EFHShifttarget EFHTarget
		FROM [mor].[CONOPS_MOR_SHIFT_INFO_V] a WITH (NOLOCK)
		LEFT JOIN RawEFH efh
		ON a.SHIFTID = efh.shiftid
		LEFT JOIN EFHTarget t
		ON t.shiftdate = efh.shiftid
		GROUP BY a.SITEFLAG, a.SHIFTFLAG, a.ShiftStartDateTime, HOS, EFHShifttarget
	),

	Tonnage AS (
		SELECT Siteflag,
			   shiftflag,
			   ISNULL(actual, 0) actual,
			   --((HOS + 1)/12) * t.shifttarget Target,
			   t.shifttarget Target,
			   t.shifttarget,
			   HOS,
			   ShiftStartDateTime,
			   ShiftEndDateTime
		FROM TonnageRaw ta
		LEFT JOIN TotalTarget t
		ON ta.shiftid = t.Shiftid
		WHERE rn = 1
	)

	SELECT t.shiftflag,
		   t.siteflag,
		   t.HOS + 1 HOS,
		   DATEADD(hour, t.HOS + 1, t.ShiftStartDateTime) HR,
		   t.ShiftStartDateTime,
		   t.ShiftEndDateTime,
		   CASE WHEN t.Target = 0 OR e.EFHTarget = 0
				THEN 0
				ELSE (ISNULL((t.actual / t.Target), 0) * ISNULL((e.EFH / e.EFHTarget), 0)) * 100
		   END AS Haulage
	FROM Tonnage t
	LEFT JOIN EFH e
	ON t.shiftflag = e.SHIFTFLAG AND t.HOS = e.HOS


