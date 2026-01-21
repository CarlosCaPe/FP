CREATE VIEW [ABR].[CONOPS_ABR_DELTA_J_V] AS


  
    
--select * from [abr].[CONOPS_ABR_DELTA_J_V]     
CREATE VIEW [ABR].[CONOPS_ABR_DELTA_J_V]     
AS    
    
    
    
WITH Tons AS (    
SELECT     
siteflag,    
shiftflag,    
shiftid,    
shiftstartdatetime,    
shiftenddatetime,    
SUM(TotalMaterialMined) TotalMaterialMined,    
TimeInHour,    
Shiftseq    
FROM [abr].[CONOPS_ABR_EQMT_SHOVEL_HOURLY_TOTALMATERIALMINED_V]    
GROUP BY siteflag, shiftflag, shiftid,shiftstartdatetime, shiftenddatetime, TimeInHour, Shiftseq    
),    
    
TonsTarget AS (    
SELECT     
shiftid,    
SUM(ShovelShiftTarget) ShiftTarget
from [abr].[CONOPS_ABR_SHOVEL_SHIFT_TARGET_V]
GROUP BY shiftid),  
    
HourlyTons AS (    
SELECT    
siteflag,    
shiftflag,    
shiftstartdatetime,    
shiftenddatetime,    
TotalMaterialMined,     
shiftTarget/12.0 AS TotalMaterialMinedTarget,  
CASE WHEN shiftTarget IS NULL OR shiftTarget = 0 THEN 0 
ELSE (TotalMaterialMined/(shiftTarget/12.0)) END AS HourlyTons,    
TimeInHour,    
Shiftseq    
FROM Tons a    
LEFT JOIN TonsTarget b On a.shiftid = b.shiftid
),    
    
EFH AS (    
SELECT     
shiftflag,    
BreakByHour AS TimeInHour,    
EFH,    
EFHShiftTarget AS EFHTarget,    
CASE WHEN EFHShiftTarget IS NULL OR EFHShiftTarget = 0 THEN 0 
ELSE (EFH/EFHShiftTarget) END AS HourlyEFH    
FROM [abr].[CONOPS_ABR_EFH_V])    
    
SELECT    
siteflag,    
a.shiftflag,    
shiftstartdatetime,    
shiftenddatetime,    
TotalMaterialMined,    
TotalMaterialMinedTarget,    
ISNULL(ROUND(EFH,0),0) EFH,    
ISNULL(EFHTarget,0) EFHTarget,  
--ISNULL(ROUND((HourlyTons * HourlyEFH) * 100,0),0) AS DeltaJ,
CASE WHEN TotalMaterialMinedTarget IS NULL OR TotalMaterialMinedTarget = 0 OR EFHTarget IS NULL OR EFHTarget = 0 THEN 0 
ELSE ISNULL(ROUND(((TotalMaterialMined*EFH) / (TotalMaterialMinedTarget*EFHTarget) * 100),0),0) END AS DeltaJ,
a.TimeInHour    
FROM HourlyTons a    
LEFT JOIN EFH b On a.shiftflag = b.shiftflag AND a.TimeInHour = b.TimeInHour    
    
    
    
  
