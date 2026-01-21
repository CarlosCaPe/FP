CREATE VIEW [sie].[CONOPS_SIE_DAILY_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V] AS
  
  
--select * from [sie].[CONOPS_SIE_DAILY_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V] WITH (NOLOCK)  
  
CREATE VIEW [sie].[CONOPS_SIE_DAILY_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V]   
AS  
  
WITH TGT AS (  
SELECT   
shiftflag,  
shiftid,
destination,  
ShovelShiftTarget,  
shoveltarget  
FROM [sie].[CONOPS_SIE_DAILY_SHOVEL_SHIFT_TARGET_V]  
WHERE destination = 'Crusher'),  
  
FinalTarget AS (  
SELECT  
shiftflag, 
shiftid,
ROUND(SUM(shoveltarget)/1000.0,1) AS MillOreTarget,  
ROUND(SUM(ShovelShiftTarget)/1000.0,1) AS MillOreShiftTarget  
FROM TGT  
--WHERE shiftflag = 'curr'  
GROUP BY shiftflag,shiftid,destination)  
  
  
SELECT  
shiftflag,
shiftid,
'Crusher' [Location],  
SUM(MillOreTarget) AS MillOreTarget,  
SUM(MillOreShiftTarget) AS MillOreShiftTarget  
FROM FinalTarget  
GROUP BY shiftid,Shiftflag  
  
   
  
  
