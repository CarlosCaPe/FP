CREATE VIEW [sie].[CONOPS_SIE_EOS_LINEUP_DRILL_V] AS
  
  
  
--select * from [sie].[CONOPS_SIE_EOS_LINEUP_DRILL_V] where shiftflag = 'curr'  
CREATE VIEW [sie].[CONOPS_SIE_EOS_LINEUP_DRILL_V]  
AS  
  
  
WITH EqmtStatus AS (  
  SELECT SHIFTINDEX,  
      site_code,  
      Drill_ID,  
      startdatetime AS StatusStart,  
      [status] AS StatusName  
  FROM [sie].[drill_asset_efficiency_v] WITH (NOLOCK)  
 ),  
  
Drill AS (  
SELECT  
shiftindex,  
CASE [EQUIPMENTMODEL] WHEN 'ADS PV351' THEN 'DR' + LEFT(EQMT, 2)ELSE EQMT  
END AS Equipment  
FROM (  
SELECT  
shiftindex,  
REPLACE([EQUIPMENTNUMBER], ' ','') AS EQMT,  
EQUIPMENTMODEL  
FROM [sie].[DRILL_UTILIZATION] WITH (NOLOCK)) x )  
  
SELECT DISTINCT  
a.siteflag,  
a.shiftflag,  
a.shiftid,  
Equipment AS DrillId,  
StatusName,  
StatusStart  
FROM [sie].[CONOPS_SIE_SHIFT_INFO_V] a  
LEFT JOIN Drill b  
ON a.SHIFTINDEX = b.SHIFTINDEX  
LEFT JOIN EqmtStatus c ON a.SHIFTINDEX = c.SHIFTINDEX AND b.Equipment = c.Drill_ID  
WHERE StatusName = 'Ready'  
AND c.StatusStart < DATEADD(MINUTE,51,SHIFTSTARTDATETIME)  
  
  
  
