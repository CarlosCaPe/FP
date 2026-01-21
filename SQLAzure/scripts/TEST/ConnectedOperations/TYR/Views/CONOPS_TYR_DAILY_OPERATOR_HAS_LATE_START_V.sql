CREATE VIEW [TYR].[CONOPS_TYR_DAILY_OPERATOR_HAS_LATE_START_V] AS


  
-- SELECT * FROM [tyr].[CONOPS_TYR_DAILY_OPERATOR_HAS_LATE_START_V] WITH (NOLOCK) WHERE Shiftflag = 'PREV'  
CREATE VIEW [TYR].[CONOPS_TYR_DAILY_OPERATOR_HAS_LATE_START_V]   
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
        AND oper.unit_code IN (1, 2)  
        AND oper.logintime > 1800 AND oper.logintime < 3600 --Only looks until 1st hour in the Shift  
        AND trim(eroot.site_code) = 'TYR'  
        AND oper.logintime <> 0  
),   
  
FirstLoadTruck AS (  
 SELECT l.SHIFTINDEX,  
     l.SITE_CODE,  
     l.OPER ,  
     l.TIMELOAD_TS,  
     ROW_NUMBER() OVER (PARTITION BY l.SHIFTINDEX, l.OPER, l.SITE_CODE ORDER BY l.TIMELOAD_TS) AS rn  
 FROM [dbo].[LH_LOAD] l  
 WHERE l.SITE_CODE = 'TYR'  
),   
  
FirstLoadShovel AS (  
 SELECT l.SHIFTINDEX,  
     l.SITE_CODE,  
     l.EOPER AS OPER,  
     l.TIMELOAD_TS,  
     ROW_NUMBER() OVER (PARTITION BY l.SHIFTINDEX, l.EOPER, l.SITE_CODE ORDER BY l.TIMELOAD_TS) AS rn  
 FROM [dbo].[LH_LOAD] l  
 WHERE l.SITE_CODE = 'TYR'  
)  
  
SELECT [shift].shiftflag,  
    [shift].[siteflag],  
	[shift].[shiftid],  
    [OperatorLateStart].SHIFTINDEX,  
    eqmtid,  
    unit_code,  
    --RIGHT('0000000000' + [OperatorId], 10) [OperatorId],  
    [OperatorId],  
    CASE WHEN [OperatorId] IS NULL OR [OperatorId] = -1 THEN NULL  
    ELSE concat([img].[value],[OperatorId],'.jpg') END as OperatorImageURL,  
    OperatorName,  
    [FirstLoginDateTime],  
    [shift].ShiftStartDateTime,  
    FirstLoginTime,  
    ShiftState,  
    --DATEDIFF(Minute, ShiftStartDateTime, [FirstLoginDateTime]) [LateStartMinute],  
    [FirstLoadDateTime],  
    [FirstLoadTS]  
    --DATEDIFF(Minute, ShiftStartDateTime, [FirstLoginDateTime]) - 15 [FirstLoad]  
FROM [tyr].[CONOPS_TYR_EOS_SHIFT_INFO_V] [shift] WITH (NOLOCK)  
LEFT JOIN (  
 SELECT [LateStart].shiftindex,  
     [LateStart].site_code,  
     [LateStart].eqmtid,  
     [LateStart].unit_code,  
     RIGHT('0000000000' + [LateStart].OPERID, 10) [OperatorId],  
     --[LateStart].OPERID [OperatorId],  
     [LateStart].name [OperatorName],  
     [LateStart].ShiftState,  
     [FirstLoginTime] [FirstLoginDateTime],  
     LEFT(CAST([LateStart].FirstLoginTime AS TIME(0)), 5) [FirstLoginTime],  
     CASE [LateStart].UNIT_CODE  
    WHEN 1 THEN DATEADD(MINUTE, -15, [flt].TIMELOAD_TS)  
    WHEN 2 THEN DATEADD(MINUTE, -15, [fls].TIMELOAD_TS)  
    ELSE NULL  
     END [FirstLoadDateTime],  
     CASE [LateStart].UNIT_CODE  
    WHEN 1 THEN LEFT(CAST(DATEADD(MINUTE, -15, [flt].TIMELOAD_TS) AS TIME(0)), 5)  
    WHEN 2 THEN LEFT(CAST(DATEADD(MINUTE, -15, [fls].TIMELOAD_TS) AS TIME(0)), 5)  
    ELSE NULL  
     END [FirstLoadTS]  
 FROM cte [LateStart]   
 LEFT JOIN FirstLoadTruck [flt]  
 ON [LateStart].SHIFTINDEX = [flt].SHIFTINDEX  
    AND [LateStart].OPERID = [flt].OPER  
 