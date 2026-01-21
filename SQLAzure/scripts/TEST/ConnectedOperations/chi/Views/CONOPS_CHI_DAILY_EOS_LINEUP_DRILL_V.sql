CREATE VIEW [chi].[CONOPS_CHI_DAILY_EOS_LINEUP_DRILL_V] AS
  
    
    
    
    
    
    
--select * from [chi].[CONOPS_CHI_DAILY_EOS_LINEUP_DRILL_V] where shiftflag = 'prev'    
CREATE VIEW [chi].[CONOPS_CHI_DAILY_EOS_LINEUP_DRILL_V]    
AS    
    
    
WITH EqmtStatus AS (    
  SELECT SHIFTINDEX,    
      site_code,    
      Drill_ID,    
      startdatetime AS StatusStart,    
      [status] AS StatusName    
  FROM [chi].[drill_asset_efficiency_v] WITH (NOLOCK)    
 ),    
    
Drill AS (    
SELECT    
shiftindex,    
REPLACE([EQUIPMENTNUMBER], ' ','') AS EQMT    
FROM [chi].[DRILL_UTILIZATION] WITH (NOLOCK))    
    
SELECT DISTINCT    
a.siteflag,    
a.shiftflag,    
a.shiftid,    
--'AC' + RIGHT(CONCAT('00', SUBSTRING(EQMT, CHARINDEX('C', EQMT)+1, len(EQMT))) , 2) as DrillId,    
EQMT AS DrillId,    
StatusName,    
StatusStart    
FROM [chi].[CONOPS_CHI_EOS_SHIFT_INFO_V] a    
LEFT JOIN Drill b    
ON a.SHIFTINDEX = b.SHIFTINDEX    
LEFT JOIN EqmtStatus c ON a.SHIFTINDEX = c.SHIFTINDEX AND b.EQMT = c.Drill_ID    
WHERE StatusName = 'Ready'    
AND c.StatusStart < DATEADD(MINUTE,51,SHIFTSTARTDATETIME)    
    
    
    
  
