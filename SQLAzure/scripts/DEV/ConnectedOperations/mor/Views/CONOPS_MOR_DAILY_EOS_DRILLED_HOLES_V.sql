CREATE VIEW [mor].[CONOPS_MOR_DAILY_EOS_DRILLED_HOLES_V] AS
  
  
  
--SELECT * FROM [MOR].[CONOPS_MOR_DAILY_EOS_DRILLED_HOLES_V] WHERE SHIFTFLAG = 'PREV'  
CREATE VIEW [MOR].[CONOPS_MOR_DAILY_EOS_DRILLED_HOLES_V]  
AS  
  
SELECT  
 siteflag,  
 shiftflag,  
 KPI,  
 ActualValue,  
 TargetValue,  
 CASE   
  WHEN ActualValue = TargetValue THEN 'Within Plan'  
  WHEN ActualValue < TargetValue THEN 'Below Plan'  
  ELSE 'Exceeds Plan'   
 END AS Status  
FROM  
(  
 SELECT  
  siteflag,  
  SHIFTFLAG,  
  ISNULL(SUM(HolesDrilled), 0) AS HolesDrilled,  
  ISNULL(AVG([HolesDrilledShiftTarget]), 0) AS HolesDrilledShiftTarget  
 FROM [MOR].[CONOPS_MOR_DAILY_DB_DRILL_PLAN_V] (NOLOCK)  
 GROUP BY siteflag, shiftflag  
) a  
CROSS APPLY (  
VALUES  
 ('Drilled Holes', HolesDrilled, HolesDrilledShiftTarget)  
) c (KPI, ActualValue, TargetValue);
  
