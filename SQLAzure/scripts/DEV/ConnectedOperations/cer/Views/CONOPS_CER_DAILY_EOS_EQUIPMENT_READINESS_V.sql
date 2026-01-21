CREATE VIEW [cer].[CONOPS_CER_DAILY_EOS_EQUIPMENT_READINESS_V] AS

  
    
    
    
    
    
    
    
--select * from [CER].[CONOPS_CER_DAILY_EOS_EQUIPMENT_READINESS_V] where shiftflag = 'prev'    
CREATE VIEW [cer].[CONOPS_CER_DAILY_EOS_EQUIPMENT_READINESS_V]    
AS    
    
WITH EqReadinessTarget AS(    
 SELECT TOP 1    
  SITEFLAG,    
  (AVGNUMBERREADYKOM930 + AVGNUMBERREADYCAT793) / 2 AS TruckReadinessTarget,    
  0 AS ShovelReadinessTarget,    
  (PVREADINESS + RL8READINESS) AS DrillReadinessTarget    
 FROM cer.PLAN_VALUES WITH (NOLOCK)    
 WHERE TITLE = FORMAT(GETDATE(), 'MMM yyyy', 'en-US')    
)    
    
SELECT    
 site_code AS siteflag,    
 shiftflag,    
 KPI,    
 SUM(ActualValue) AS ActualValue,    
 SUM(TargetValue) AS TargetValue,    
 CASE     
  WHEN SUM(ActualValue) = SUM(TargetValue) THEN 'Within Plan'    
  WHEN SUM(ActualValue) < SUM(TargetValue) THEN 'Below Plan'    
  ELSE 'Exceeds Plan'     
 END AS Status    
FROM(    
    
 SELECT    
  SITE_CODE,    
  shiftflag,    
  shiftindex,    
  ROUND([Truck],0) AS TruckReadiness,     
  ROUND(eq.TruckReadinessTarget,0) AS TruckReadinessTarget,     
  ROUND([Shovel],0) AS ShovelReadiness,     
  ROUND(eq.ShovelReadinessTarget,0) AS ShovelReadinessTarget,     
  ROUND([Drill],0) AS DrillReadiness,   ROUND(eq.DrillReadinessTarget,0) AS DrillReadinessTarget    
 FROM(    
  SELECT    
    
   r.SITE_CODE,    
   s.shiftflag,    
   r.SHIFTINDEX,    
   MainCategory,    
   SUM(ReadyDurationByEquipment)/AVG(TotalDurationByEquipment) AS Ready    
  FROM    
  (    
   SELECT    
    site_code,    
    shiftindex,    
    CASE unit     
     WHEN 1 THEN 'Truck'    
     WHEN 2 THEN 'Shovel'    
     WHEN 12 THEN 'Drill'    
    END AS MainCategory,    
    eqmt AS Equipment,    
    SUM(duration) AS TotalDurationByEquipment,    
    SUM(CASE WHEN category IN (1,2) THEN duration ELSE 0 END) AS ReadyDurationByEquipment    
   FROM dbo.status_event WITH (NOLOCK)     
   WHERE    
    unit IN (1,2,12) --trucks, shovels, drills    
    AND status <> 0    
    AND 1 = CASE WHEN unit = 2 AND eqmt like 'L%' THEN 0 ELSE 1 END --exclude loaders    
   GROUP BY site_code, shiftindex, eqmt, unit    
  ) as r    
  LEFT JOIN CER.CONOPS_CER_EOS_SHIFT_INFO_V s    
   ON r.site_code = s.SITEFLAG    
   AND r.shiftindex = s.ShiftIndex    
  WHERE s.shiftflag IS NOT NULL    
  GROUP BY r.site_code, s.shiftflag, r.shiftindex, r.MainCategory    
 ) a    
 PIVOT(    
  AVG(Ready)    
  FOR MainCategory IN ([Truck], [Shovel], [Drill])    
 ) AS pvt    
 CROSS JOIN EqReadinessTarget eq    
) a    
CROSS APPLY (    
VALUES    
 ('Trucks', TruckReadiness, TruckReadinessTarget),    
 ('Shovels', ShovelReadiness, ShovelReadinessTarget),    
 ('Drills', DrillReadiness, DrillReadinessTarget)    
) c (KPI, ActualValue, TargetValue)
GROUP BY site_code, shiftflag, KPI;    
    
    
    
    
    
  

