CREATE VIEW [cer].[CONOPS_CER_OPERATOR_HAS_LATE_START_V] AS

  
   
-- SELECT * FROM [cer].[CONOPS_CER_OPERATOR_HAS_LATE_START_V] WITH (NOLOCK) WHERE Shiftflag = 'PREV'    
CREATE VIEW [cer].[CONOPS_CER_OPERATOR_HAS_LATE_START_V]    
AS    
    
WITH cte AS (    
SELECT DISTINCT oper.shiftindex
    , eroot.siteflag AS site_code
    , oper.operid
    , oper.name
    , oper.eqmtid
    , oper.unit_code
    , MIN( dateadd(second, oper.logintime, ShiftStartDateTime)
    ) OVER (PARTITION BY oper.operid, eroot.shiftindex) AS FirstLoginTime
    , rt.name AS ShiftState
    , 0 AS AnticipatedShiftStart
    , ROW_NUMBER() OVER (PARTITION BY oper.operid, eroot.shiftindex, eroot.siteflag ORDER BY oper.logintime) AS rn
    FROM cer.CONOPS_CER_SHIFT_INFO_V (nolock) AS eroot
INNER JOIN dbo.lh_oper_total_sum (nolock) AS oper
	ON eroot.shiftindex = oper.shiftindex
	AND eroot.siteflag = oper.site_code
LEFT JOIN dbo.status_event (nolock) AS se
	ON se.shiftindex = oper.shiftindex
	AND se.eqmt = oper.eqmtid
	AND 900 >= se.starttime
	AND 900 < se.endtime
	AND se.site_code = oper.site_code
INNER JOIN dbo.lh_reason (nolock) AS rt
	ON se.shiftindex = rt.shiftindex
	AND se.reason = rt.reason
	AND rt.status = se.status
	AND se.site_code = rt.site_code
WHERE trim(oper.operid) not in ('mmsunk', '')
	AND oper.unit_code IN (1, 2)
	AND oper.logintime > 900 AND oper.logintime < 3600 --Only looks until 1st hour in the Shift
	AND trim(eroot.siteflag) = 'CER'
	AND oper.logintime <> 0
	AND rt.STATUS NOT IN (1,2)  --Status not in Production & Down  
),     
    
FirstLoadTruck AS (    
 SELECT l.SHIFTINDEX,    
     l.SITE_CODE,    
     l.OPER ,    
     l.TIMELOAD_TS,    
     ROW_NUMBER() OVER (PARTITION BY l.SHIFTINDEX, l.OPER, l.SITE_CODE ORDER BY l.TIMELOAD_TS) AS rn    
 FROM [dbo].[LH_LOAD] l  WITH (NOLOCK)  
 WHERE l.SITE_CODE = 'CER'    
),     
    
FirstLoadShovel AS (    
 SELECT l.SHIFTINDEX,    
     l.SITE_CODE,    
     l.EOPER AS OPER,    
     l.TIMELOAD_TS,    
     ROW_NUMBER() OVER (PARTITION BY l.SHIFTINDEX, l.EOPER, l.SITE_CODE ORDER BY l.TIMELOAD_TS) AS rn    
 FROM [dbo].[LH_LOAD] l   WITH (NOLOCK) 
 WHERE l.SITE_CODE = 'CER'    
)    
    
SELECT [shift].shiftflag,    
    [shift].[siteflag],    
    [OperatorLateStart].SHIFTINDEX,    
    eqmtid,    
    unit_code,    
    RIGHT('0000000000' + [OperatorId], 10) [OperatorId],    
    CASE WHEN [PersonnelId] IS NOT NULL OR [PersonnelId] != -1    
      THEN concat(lookups.[value],RIGHT('0000000000' + [PersonnelId], 10),'.jpg')    
   WHEN ([PersonnelId] IS NULL OR [PersonnelId] = -1) AND ([OperatorId] IS NOT NULL OR [OperatorId] != -1)    
      THEN concat(lookups.[value],RIGHT('0000000000' + [OperatorId], 10),'.jpg')    
   WHEN ([PersonnelId] IS NULL OR [PersonnelId] = -1) AND ([OperatorId] IS NULL OR [OperatorId] = -1)    
   THEN NULL    
    END as OperatorImageURL,    
    OperatorName,    
    [FirstLoginDateTime],    
    [shift].ShiftStartDateTime,    
    FirstLoginTime,    
    ShiftState,    
    [FirstLoadDateTime],    
    [FirstLoadTS]    
    --DATEDIFF(Minute, ShiftStartDateTime, [FirstLoginDateTime]) - 15 [FirstLoad]    
FROM [cer].[CONOPS_CER_SHIFT_INFO_V] [shift] WITH (NOLOCK)    
LEFT JOIN (    
 SELECT [LateStart].shiftindex,    
     [LateStart].site_code,    
     [LateStart].eqmtid,    
     [LateStart].unit_code,    
     [LateStart].OPERID [OperatorId],    
     [opm].[Personnel_Id] AS PersonnelId,    
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