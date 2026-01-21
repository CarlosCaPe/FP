CREATE VIEW [CHI].[CONOPS_CHI_DAILY_DELTA_J_V] AS
  
    
      
      
      
      
      
--select * from [chi].[CONOPS_CHI_DAILY_DELTA_J_V]       
CREATE VIEW [chi].[CONOPS_CHI_DAILY_DELTA_J_V]       
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
FROM [chi].[CONOPS_CHI_DAILY_EQMT_SHOVEL_HOURLY_TOTALMATERIALMINED_V]      
GROUP BY siteflag, shiftflag, shiftid,shiftstartdatetime, shiftenddatetime, TimeInHour, Shiftseq      
),      
      
TonsTarget AS (      
SELECT       
shiftid,      
shiftTarget      
from [chi].[CONOPS_CHI_SHIFT_TARGET_V]),      
      
HourlyTons AS (      
SELECT      
siteflag,      
shiftflag,    
a.shiftid,
shiftstartdatetime,      
shiftenddatetime,      
TotalMaterialMined,      
--ROUND(((Shiftseq/12.0) * shiftTarget),0) AS TotalMaterialMinedTarget,      
shiftTarget/12.0 AS TotalMaterialMinedTarget,    
(TotalMaterialMined/(shiftTarget/12.0)) HourlyTons,      
TimeInHour,      
Shiftseq      
FROM Tons a      
LEFT JOIN TonsTarget b On a.shiftid = b.shiftid),      
      
EFH AS (      
SELECT       
shiftflag,     
shiftid,
BreakByHour AS TimeInHour,      
EFH,      
EFHShiftTarget AS EFHTarget,      
(EFH/EFHShiftTarget) AS HourlyEFH      
FROM [chi].[CONOPS_CHI_DAILY_EFH_V])      
      
SELECT      
siteflag,      
a.shiftflag,   
a.shiftid,
shiftstartdatetime,      
shiftenddatetime,      
TotalMaterialMined,      
TotalMaterialMinedTarget,      
ISNULL(ROUND(EFH,0),0) EFH,      
ISNULL(EFHTarget,0) EFHTarget,    
--ISNULL(ROUND((HourlyTons * HourlyEFH) * 100,0),0) AS DeltaJ,      
ISNULL(ROUND(((TotalMaterialMined*EFH) / (TotalMaterialMinedTarget*EFHTarget) * 100),0),0) AS DeltaJ,  
a.TimeInHour      
FROM HourlyTons a      
LEFT JOIN EFH b On a.shiftid = b.shiftid AND a.TimeInHour = b.TimeInHour      
      
      
      
    
  
