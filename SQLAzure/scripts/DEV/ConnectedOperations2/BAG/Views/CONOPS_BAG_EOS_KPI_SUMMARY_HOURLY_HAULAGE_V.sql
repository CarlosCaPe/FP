CREATE VIEW [BAG].[CONOPS_BAG_EOS_KPI_SUMMARY_HOURLY_HAULAGE_V] AS




-- SELECT * FROM [bag].[CONOPS_BAG_EOS_KPI_SUMMARY_HOURLY_HAULAGE_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [BAG].[CONOPS_BAG_EOS_KPI_SUMMARY_HOURLY_HAULAGE_V]  
AS  
  
WITH RawEFH AS (
	SELECT
		siteflag,
		shiftid,
		shiftstartdatetime,
		BreakByHour as CurrentTime,
		DATEDIFF(HOUR, shiftstartdatetime, BreakByHour) AS HOS,
		EFH
	FROM BAG.CONOPS_BAG_EFH_V
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
		FROM BAG.[CONOPS_BAG_SHIFT_LINE_GRAPH_V] (NOLOCK)
	) m
),

EFHTarget AS (
	SELECT substring(replace(EffectiveDate,'-',''),3,4) as shiftdate,
		   EFH as EFHShifttarget
	FROM [bag].[plan_values_prod_sum] with (nolock)
),

TotalTarget AS (
	SELECT FORMATSHIFTID,
		   CAST(SUM(TOTALMINED) AS INT) as shifttarget
	FROM [bag].[plan_values] WITH (NOLOCK)
	GROUP BY FORMATSHIFTID 
),

EFH AS (
	SELECT a.SITEFLAG
		  ,a.SHIFTFLAG
		  ,a.ShiftStartDateTime
		  ,HOS
		  ,ISNULL(AVG(EFH), 0) EFH
		  --,((HOS + 1)/12) * t.EFHShifttarget EFHTarget
		  ,t.EFHShifttarget EFHTarget
	FROM [bag].[CONOPS_BAG_SHIFT_INFO_V] a WITH (NOLOCK)
	LEFT JOIN RawEFH efh
	ON a.SHIFTID = efh.shiftid
	LEFT JOIN EFHTarget t
	ON t.shiftdate = LEFT(efh.shiftid, 4)
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
	ON ta.shiftid = t.FORMATSHIFTID
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



