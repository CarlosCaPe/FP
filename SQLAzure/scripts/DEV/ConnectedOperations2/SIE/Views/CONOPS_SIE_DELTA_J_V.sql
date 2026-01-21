CREATE VIEW [SIE].[CONOPS_SIE_DELTA_J_V] AS
  
       
--select * from [sie].[CONOPS_SIE_DELTA_J_V]         
CREATE VIEW [sie].[CONOPS_SIE_DELTA_J_V]         
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
FROM [sie].[CONOPS_SIE_EQMT_SHOVEL_HOURLY_TOTALMATERIALMINED_V]        
GROUP BY siteflag, shiftflag, shiftid,shiftstartdatetime, shiftenddatetime, TimeInHour, Shiftseq        
),        
        
TonsTarget AS (        
SELECT        
shiftflag,        
SUM(shiftTarget) shiftTarget        
FROm (        
SELECT         
shiftflag,        
SUM(shovelshifttarget) shiftTarget        
FROM [sie].[CONOPS_SIE_SHOVEL_SHIFT_TARGET_V]        
GROUP BY shiftflag) x        
GROUP BY shiftflag),        
        
HourlyTons AS (        
SELECT        
siteflag,        
a.shiftflag,        
shiftstartdatetime,        
shiftenddatetime,        
TotalMaterialMined,        
--ROUND(((Shiftseq/12.0) * shiftTarget),0) AS TotalMaterialMinedTarget,        
shiftTarget/12.0 AS TotalMaterialMinedTarget,      
(TotalMaterialMined/(shiftTarget/12.0)) HourlyTons,        
TimeInHour,        
Shiftseq        
FROM Tons a        
LEFT JOIN TonsTarget b On a.shiftflag = b.shiftflag),        
        
EFH AS (        
SELECT         
shiftflag,        
BreakByHour AS TimeInHour,        
EFH,        
EFHShiftTarget AS EFHTarget, 
CASE WHEN EFHShiftTarget IS NULL OR EFHShiftTarget = 0 THEN 0 
ELSE (EFH/EFHShiftTarget) END AS HourlyEFH        
FROM [sie].[CONOPS_SIE_EFH_V])        
        
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
        
        
        
      
    
  
