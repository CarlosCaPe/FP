CREATE VIEW [cer].[CONOPS_CER_DAILY_EOS_TONS_MINED_V] AS

  
  
  
  
  
  
--SELECT * FROM [CER].[CONOPS_CER_DAILY_EOS_TONS_MINED_V] WHERE SHIFTFLAG = 'PREV'  
CREATE VIEW [cer].[CONOPS_CER_DAILY_EOS_TONS_MINED_V]  
AS  
  
WITH TonsTarget AS(  
 SELECT   
  t.shiftid,  
  s.shiftflag,  
  ROUND(AVG(t.MaterialMinedShiftTarget) / 1000.0 ,1) AS TotalMaterialMinedTarget,  
  ROUND(AVG(t.MaterialMovedShiftTarget) / 1000.0 ,1) AS TotalMaterialMovedTarget  
 FROM cer.conops_cer_shovel_target_v t  
 LEFT JOIN cer.CONOPS_CER_EOS_SHIFT_INFO_V s  
 ON t.shiftid = s.shiftid  
 GROUP BY t.Shiftid, s.shiftflag  
)  
  
SELECT  
 siteflag,  
 shiftflag,  
 --shiftid,
 KPI,  
 NULL AS ChildKPI,  
 ActualValue,  
 TargetValue,  
 CASE   
  WHEN ActualValue = TargetValue THEN 'Within Plan'  
  WHEN ActualValue < TargetValue THEN 'Below Plan'  
  ELSE 'Exceeds Plan'   
 END AS Status  
FROM(  
 SELECT  
  ov.siteflag,  
  ov.shiftflag,  
  --ov.shiftid,
  ROUND(SUM(ov.TotalMaterialMined)/1000.0,1) AS TotalMaterialMined,  
  SUM(tt.TotalMaterialMinedTarget) AS TotalMaterialMinedTarget,  
  ROUND(SUM(ov.TotalmaterialMoved)/1000.0,1) AS TotalMaterialMoved,  
  SUM(tt.TotalMaterialMovedTarget) AS TotalMaterialMovedTarget  
 FROM [CER].[CONOPS_CER_DAILY_EOS_TOTAL_MATERIAL_V] ov  
 LEFT JOIN TonsTarget tt  
 ON ov.shiftflag = tt.shiftflag  AND ov.shiftid = tt.shiftid  
 GROUP BY ov.siteflag, ov.shiftflag
) a  
CROSS APPLY (  
VALUES  
 ('Total Material Moved', TotalMaterialMoved, TotalMaterialMovedTarget),  
 ('Total Material Mined', TotalMaterialMined, TotalMaterialMinedTarget)  
) c (KPI, ActualValue, TargetValue)  
  
UNION  
  
SELECT  
 siteflag,  
 SHIFTFLAG,  
 --shiftid,
 Name AS KPI,  
 ChildKPI,  
 SUM(ActualValue) AS ActualValue,  
 SUM(TargetValue) AS TargetValue,  
 CASE   
  WHEN SUM(ActualValue) = SUM(TargetValue) THEN 'Within Plan'  
  WHEN SUM(ActualValue) < SUM(TargetValue) THEN 'Below Plan'  
  ELSE 'Exceeds Plan'   
 END AS Status  
FROM [CER].[CONOPS_CER_DAILY_MATERIAL_DELIVERED_TO_CHRUSHER_V]  
CROSS APPLY  
(  
  VALUES  
    ('Leach', LeachActual, LeachShiftTarget),  
    ('Mill Ore', MillOreActual, MillOreShiftTarget),  
 (NULL, (LeachActual + MillOreActual), (LeachShiftTarget + MillOreShiftTarget))  
) c (ChildKPI, ActualValue, TargetValue)  
GROUP BY siteflag, SHIFTFLAG, Name, ChildKPI   
  

