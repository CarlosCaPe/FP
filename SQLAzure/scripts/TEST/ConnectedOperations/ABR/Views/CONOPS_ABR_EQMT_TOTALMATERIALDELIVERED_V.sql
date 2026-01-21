CREATE VIEW [ABR].[CONOPS_ABR_EQMT_TOTALMATERIALDELIVERED_V] AS



--select * from [abr].[CONOPS_ABR_EQMT_TOTALMATERIALDELIVERED_V]  
CREATE VIEW [ABR].[CONOPS_ABR_EQMT_TOTALMATERIALDELIVERED_V]  
AS  
  
  
WITH CTE AS (  
SELECT   
sd.shiftid,  
t.FieldId AS [TruckId],  
SUM(sd.FieldLsizetons) AS [Tons]  
FROM [abr].shift_dump_v sd WITH (NOLOCK)  
LEFT JOIN [abr].shift_eqmt t WITH (NOLOCK) ON t.Id = sd.FieldTruck  
GROUP BY sd.shiftid, t.FieldId)  
  
  
SELECT  
siteflag,  
a.shiftid,  
TruckId,  
Tons As TotalMaterialDelivered  
FROM [abr].[CONOPS_ABR_SHIFT_INFO_V] a  
LEFT JOIN CTE b on a.SHIFTID = b.shiftid  
WHERE TruckId IS NOT NULL  
  
  
  
  
