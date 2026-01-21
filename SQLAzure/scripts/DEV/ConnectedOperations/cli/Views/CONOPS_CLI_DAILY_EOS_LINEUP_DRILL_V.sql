CREATE VIEW [cli].[CONOPS_CLI_DAILY_EOS_LINEUP_DRILL_V] AS
  
    
    
    
    
    
    
--select * from [cli].[CONOPS_CLI_DAILY_EOS_LINEUP_DRILL_V] where shiftflag = 'curr'    
CREATE VIEW [cli].[CONOPS_CLI_DAILY_EOS_LINEUP_DRILL_V]    
AS    
    
    
WITH EqmtStatus AS (    
  SELECT SHIFTINDEX,    
      site_code,    
      Drill_ID,    
      startdatetime AS StatusStart,    
      [status] AS StatusName    
  FROM [cli].[drill_asset_efficiency_v] WITH (NOLOCK)    
 ),    
    
Drill AS (    
SELECT    
shiftindex,    
REPLACE([EQUIPMENTNUMBER], ' ','') AS EQMT    
FROM [cli].[DRILL_UTILIZATION] WITH (NOLOCK))    
    
SELECT DISTINCT    
a.siteflag,    
a.shiftflag,    
a.shiftid,    
--'AC' + RIGHT(CONCAT('00', SUBSTRING(EQMT, CHARINDEX('C', EQMT)+1, len(EQMT))) , 2) as DrillId,    
EQMT AS DrillId,    
StatusName,    
StatusStart    
FROM [cli].[CONOPS_CLI_EOS_SHIFT_INFO_V] a    
LEFT JOIN Drill b    
ON a.SHIFTINDEX = b.SHIFTINDEX    
LEFT JOIN EqmtStatus c ON a.SHIFTINDEX = c.SHIFTINDEX AND b.EQMT = c.Drill_ID    
WHERE StatusName = 'Ready'    
AND c.StatusStart < DATEADD(MINUTE,51,SHIFTSTARTDATETIME)    
    
    
    
  
