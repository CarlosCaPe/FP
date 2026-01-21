CREATE VIEW [TYR].[CONOPS_TYR_EOS_LINEUP_DRILL_V] AS



  
--select * from [tyr].[CONOPS_TYR_EOS_LINEUP_DRILL_V] WHERE shiftflag = 'curr'  
CREATE VIEW [TYR].[CONOPS_TYR_EOS_LINEUP_DRILL_V]  
AS  
  
  
WITH EqmtStatus AS (  
  SELECT SHIFTINDEX,  
      site_code,  
      Drill_ID,  
      startdatetime AS StatusStart,  
      [status] AS StatusName  
  FROM [tyr].[drill_asset_efficiency_v] WITH (NOLOCK)  
 ),  
  
Drill AS (  
SELECT  
shiftindex,  
REPLACE([EQUIPMENTNUMBER], ' ','') AS EQMT  
FROM [tyr].[DRILL_UTILIZATION] WITH (NOLOCK))  
  
SELECT DISTINCT  
a.siteflag,  
a.shiftflag,  
a.shiftid,  
--'AC' + RIGHT(CONCAT('00', SUBSTRING(EQMT, CHARINDEX('C', EQMT)+1, len(EQMT))) , 2) as DrillId,  
EQMT AS DrillId,  
StatusName,  
StatusStart  
FROM [tyr].[CONOPS_TYR_SHIFT_INFO_V] a  
LEFT JOIN Drill b  
ON a.SHIFTINDEX = b.SHIFTINDEX  
LEFT JOIN EqmtStatus c ON a.SHIFTINDEX = c.SHIFTINDEX AND b.EQMT = c.Drill_ID  
WHERE StatusName = 'Ready'  
AND c.StatusStart < DATEADD(MINUTE,51,SHIFTSTARTDATETIME)  
  
  
  

