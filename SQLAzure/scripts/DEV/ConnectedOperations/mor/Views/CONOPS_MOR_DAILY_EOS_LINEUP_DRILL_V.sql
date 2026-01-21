CREATE VIEW [mor].[CONOPS_MOR_DAILY_EOS_LINEUP_DRILL_V] AS

  
    
    
    
    
    
    
--select * from [mor].[CONOPS_MOR_DAILY_EOS_LINEUP_DRILL_V] WHERE shiftflag = 'curr'    
CREATE VIEW [mor].[CONOPS_MOR_DAILY_EOS_LINEUP_DRILL_V]    
AS    
    
    
WITH EqmtStatus AS (    
  SELECT SHIFTINDEX,    
      site_code,    
      Drill_ID,    
      startdatetime AS StatusStart,    
      [status] AS StatusName    
  FROM [mor].[drill_asset_efficiency_v] WITH (NOLOCK)    
 ),    
    
Drill AS (  
SELECT  
shiftid,  
REPLACE([EQMT], ' ','') AS EQMT  
FROM [mor].[asset_efficiency] WITH (NOLOCK)
WHERE unittype = 'Drill'
)    
    
SELECT DISTINCT    
a.siteflag,    
a.shiftflag,    
a.shiftid,    
--'AC' + RIGHT(CONCAT('00', SUBSTRING(EQMT, CHARINDEX('C', EQMT)+1, len(EQMT))) , 2) as DrillId,    
EQMT AS DrillId,    
StatusName,    
StatusStart    
FROM [mor].[CONOPS_MOR_EOS_SHIFT_INFO_V] a    
LEFT JOIN Drill b    
ON a.shiftid = b.shiftid    
LEFT JOIN EqmtStatus c ON a.SHIFTINDEX = c.SHIFTINDEX AND b.EQMT = c.Drill_ID    
WHERE StatusName = 'Ready'    
AND c.StatusStart < DATEADD(MINUTE,51,SHIFTSTARTDATETIME)    
    
    
    
  

