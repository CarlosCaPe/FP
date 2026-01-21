CREATE VIEW [sie].[CONOPS_SIE_DAILY_EOS_TOTAL_MATERIAL_V] AS

  
  
  
  
--select * from [sie].[CONOPS_SIE_DAILY_EOS_TOTAL_MATERIAL_V]  
CREATE VIEW [sie].[CONOPS_SIE_DAILY_EOS_TOTAL_MATERIAL_V]  
AS  
  
  
WITH TONS AS (  
SELECT   
shiftid,  
SUM(TotalMaterialMoved) TotalMaterialMined,  
SUM(TotalMineralsMined) TotalMaterialMoved  
FROM [sie].[CONOPS_SIE_SHIFT_OVERVIEW_V]  
GROUP BY shiftid),  
  
Crusher AS (  
SELECT  
shiftflag,  
shiftid,
(SUM(LeachActual) + SUM(MillOreActual)) * 1000 AS TotalMaterialDeliveredToCrusher  
FROM [sie].[CONOPS_SIE_DAILY_MATERIAL_DELIVERED_TO_CHRUSHER_V]  
GROUP BY shiftflag,shiftid)  
  
SELECT   
a.siteflag,  
a.shiftflag,  
a.shiftid,
SUM(TotalMaterialMined) TotalMaterialMined,  
SUM(TotalMaterialMoved) TotalMaterialMoved, 
ROUND(SUM(TotalMaterialDeliveredToCrusher),0) TotalMaterialDeliveredToCrusher  
FROM [sie].[CONOPS_SIE_EOS_SHIFT_INFO_V] a  
LEFT JOIN TONS b on b.shiftid = a.shiftid   
LEFT JOIN Crusher c on a.shiftid = c.shiftid AND a.shiftflag = c.shiftflag   
GROUP BY a.siteflag,  a.shiftflag ,a.shiftid
  
  
  
  

