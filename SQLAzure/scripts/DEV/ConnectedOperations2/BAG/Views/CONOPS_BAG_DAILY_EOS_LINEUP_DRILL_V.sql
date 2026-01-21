CREATE VIEW [BAG].[CONOPS_BAG_DAILY_EOS_LINEUP_DRILL_V] AS

  
    
    
    
    
    
    
    
--select * from [bag].[CONOPS_BAG_DAILY_EOS_LINEUP_DRILL_V] where shiftflag = 'curr'    
CREATE VIEW [bag].[CONOPS_BAG_DAILY_EOS_LINEUP_DRILL_V]    
AS    
    
    
WITH EqmtStatus AS (    
  SELECT SHIFTINDEX,    
      site_code,    
      Drill_ID,    
      startdatetime AS StatusStart,    
      [status] AS StatusName    
  FROM [bag].[drill_asset_efficiency_v] WITH (NOLOCK)    
      
 ),    
    
Drill AS (
SELECT
shiftindex,
'AC' + RIGHT(CONCAT('00', SUBSTRING(EQMT, CHARINDEX('C', EQMT)+1, len(EQMT))) , 2) as DrillId
FROM (
SELECT DISTINCT
shiftindex,
REPLACE([EQMT], ' ','') AS EQMT
FROM [bag].[FLEET_EQUIPMENT_HOURLY_STATUS] WITH (NOLOCK)
WHERE UNIT = 12) x)   
    
SELECT DISTINCT    
a.siteflag,    
a.shiftflag,    
a.shiftid,    
DrillId,    
StatusName,    
StatusStart AS StatusStart    
FROM [bag].[CONOPS_BAG_EOS_SHIFT_INFO_V] a    
LEFT JOIN Drill b    
ON a.SHIFTINDEX = b.SHIFTINDEX    
LEFT JOIN EqmtStatus c ON a.SHIFTINDEX = c.SHIFTINDEX AND b.DrillId = c.Drill_ID    
WHERE StatusName = 'Ready'    
AND c.StatusStart < DATEADD(MINUTE,51,SHIFTSTARTDATETIME)    
    
    
    
  

