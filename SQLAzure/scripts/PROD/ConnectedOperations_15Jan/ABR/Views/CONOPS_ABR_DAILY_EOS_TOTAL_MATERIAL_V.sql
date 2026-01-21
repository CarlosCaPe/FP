CREATE VIEW [ABR].[CONOPS_ABR_DAILY_EOS_TOTAL_MATERIAL_V] AS




  
--select * from [abr].[CONOPS_ABR_DAILY_EOS_TOTAL_MATERIAL_V]  
CREATE VIEW [ABR].[CONOPS_ABR_DAILY_EOS_TOTAL_MATERIAL_V]  
AS  
  
  
WITH TONS AS (  
SELECT   
shiftid,  
SUM(TotalMaterialMined) TotalMaterialMined,  
SUM(TotalMaterialMoved) TotalMaterialMoved  
FROM [abr].[CONOPS_ABR_SHIFT_OVERVIEW_V]  
GROUP BY shiftid)
  
/*Crusher AS (  
SELECT  
shiftflag,  
shiftid,
(SUM(LeachActual) + SUM(MillOreActual)) * 1000 AS TotalMaterialDeliveredToCrusher  
FROM [abr].[CONOPS_ABR_DAILY_MATERIAL_DELIVERED_TO_CHRUSHER_V]  
GROUP BY shiftflag,shiftid)  */
  
SELECT   
a.siteflag,  
a.shiftflag,  
a.shiftid,
SUM(TotalMaterialMined) TotalMaterialMined,  
SUM(TotalMaterialMoved) TotalMaterialMoved,  
--ROUND(SUM(TotalMaterialDeliveredToCrusher),0) TotalMaterialDeliveredToCrusher  
0 TotalMaterialDeliveredToCrusher
FROM [abr].[CONOPS_ABR_EOS_SHIFT_INFO_V] a  
LEFT JOIN TONS b on b.shiftid = a.shiftid   
--LEFT JOIN Crusher c on a.shiftid = c.shiftid AND a.shiftflag = c.shiftflag   
GROUP BY a.siteflag,  a.shiftflag,  a.shiftid
  
  
  
  


