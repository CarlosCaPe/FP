CREATE VIEW [TYR].[CONOPS_TYR_DRILL_OPERATOR_HAS_LATE_START_V] AS



-- SELECT * FROM [tyr].[CONOPS_TYR_DRILL_OPERATOR_HAS_LATE_START_V] WITH (NOLOCK) WHERE Shiftflag = 'PREV'
CREATE VIEW [TYR].[CONOPS_TYR_DRILL_OPERATOR_HAS_LATE_START_V] 
AS

WITH cte AS (
  SELECT DISTINCT oper.shiftindex
 		 , eroot.site_code
		 , oper.operid
		 , oper.name
		 , oper.eqmtid
		 , oper.unit_code
		 , MIN( dateadd(second, eroot.starts + oper.logintime, CAST(eroot.shiftdate AS DATETIME))
		       ) OVER (PARTITION BY oper.operid, eroot.shiftindex) AS FirstLoginTime
		 , rt.name AS ShiftState
		 , 0 AS AnticipatedShiftStart
		 , ROW_NUMBER() OVER (PARTITION BY oper.operid, eroot.shiftindex, eroot.site_code ORDER BY oper.logintime) AS rn
  FROM dbo.shift_date (nolock) AS eroot
  INNER JOIN dbo.lh_oper_total_sum (nolock) AS oper
  ON eroot.shiftindex = oper.shiftindex
	 AND eroot.site_code = oper.site_code
  LEFT JOIN dbo.status_event (nolock) AS se
  ON se.shiftindex = oper.shiftindex
	 AND se.eqmt = oper.eqmtid
	 AND 1800 >= se.starttime
	 AND 1800 < se.endtime
	 AND se.site_code = oper.site_code
  INNER JOIN dbo.lh_reason (nolock) AS rt
  ON se.shiftindex = rt.shiftindex
	 AND se.reason = rt.reason
	 AND rt.status = se.status
	 AND se.site_code = rt.site_code
  WHERE trim(oper.operid) not in ('mmsunk', '')
        AND oper.unit_code IN (12)
        AND oper.logintime > 1800 AND oper.logintime < 3600 --Only looks until 1st hour in the Shift
        AND trim(eroot.site_code) = 'TYR'
        AND oper.logintime <> 0
)

SELECT [shift].shiftflag,
	   [shift].[siteflag],
	   [OperatorLateStart].SHIFTINDEX,
	   eqmtid,
	   unit_code,
	   RIGHT('0000000000' + [OperatorId], 10) [OperatorId],
	   CASE WHEN [OperatorId] IS NULL OR [OperatorId] = -1 THEN NULL
	   ELSE concat([img].[value],[OperatorId],'.jpg') END as OperatorImageURL,
	   OperatorName,
	   [FirstLoginDateTime],
	   [shift].ShiftStartDateTime,
	   FirstLoginTime,
	   --DATEDIFF(Minute, ShiftStartDateTime, [FirstLoginDateTime]) [LateStartMinute],
	   DATEDIFF(Minute, ShiftStartDateTime, [FirstLoginDateTime]) - 15 [FirstLoad]
FROM [tyr].[CONOPS_TYR_SHIFT_INFO_V] [shift] WITH (NOLOCK)
LEFT JOIN (
	SELECT [LateStart].shiftindex,
		   [LateStart].site_code,
		   [LateStart].eqmtid,
		   [LateStart].unit_code,
		   RIGHT('0000000000' + [LateStart].OPERID, 10) [OperatorId],
		   --[LateStart].OPERID [OperatorId],
		   [LateStart].name [OperatorName],
		   [FirstLoginTime] [FirstLoginDateTime],
		   LEFT(CAST([LateStart].FirstLoginTime AS TIME(0)), 5) [FirstLoginTime]
	FROM cte [LateStart]
	WHERE rn = 1
) [OperatorLateStart]
on [OperatorLateStart].SHIFTINDEX = [shift].ShiftIndex
   AND [OperatorLateStart].site_code = [shift].siteflag
CROSS JOIN [dbo].[LOOKUPS] img WITH (NOLOCK)
WHERE [OperatorLateStart].ShiftIndex IS NOT NULL
AND img.TableCode = 'IMGURL'


