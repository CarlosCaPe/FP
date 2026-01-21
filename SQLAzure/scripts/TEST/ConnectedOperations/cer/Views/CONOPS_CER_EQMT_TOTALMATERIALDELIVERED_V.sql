CREATE VIEW [cer].[CONOPS_CER_EQMT_TOTALMATERIALDELIVERED_V] AS
  
  
  
  
  
  
--select * from [cer].[CONOPS_CER_EQMT_TOTALMATERIALDELIVERED_V]  
CREATE VIEW [cer].[CONOPS_CER_EQMT_TOTALMATERIALDELIVERED_V]  
AS  
  
  
WITH CTE AS (  
SELECT   
sd.shiftid,  
t.FieldId AS [TruckId],  
SUM(sd.FieldLsizetons) AS [Tons]  
FROM cer.SHIFT_DUMP_V sd WITH (NOLOCK)   
LEFT JOIN cer.shift_eqmt t WITH (NOLOCK) ON t.shift_eqmt_id = sd.FieldTruck  
GROUP BY sd.shiftid, t.FieldId,sd.siteflag)  
  
  
SELECT  
siteflag,  
a.shiftid,  
TruckId,  
Tons AS TotalMaterialDelivered  
FROM [cer].[CONOPS_CER_SHIFT_INFO_V] a  
LEFT JOIN CTE b on a.SHIFTID = b.shiftid  
WHERE TruckId IS NOT NULL  
  
  
  
  
  
  
