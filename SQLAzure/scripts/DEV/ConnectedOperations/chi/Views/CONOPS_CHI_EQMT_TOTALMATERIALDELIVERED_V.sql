CREATE VIEW [chi].[CONOPS_CHI_EQMT_TOTALMATERIALDELIVERED_V] AS
  
  
  
  
  
--select * from [chi].[CONOPS_CHI_EQMT_TOTALMATERIALDELIVERED_V]  
CREATE VIEW [chi].[CONOPS_CHI_EQMT_TOTALMATERIALDELIVERED_V]  
AS  
  
WITH CTE AS (  
SELECT   
sd.shiftid,  
t.FieldId AS [TruckId],  
SUM(sd.FieldLsizetons) AS [Tons]  
FROM CHI.SHIFT_DUMP sd WITH (NOLOCK)   
LEFT JOIN CHI.shift_eqmt t WITH (NOLOCK) ON t.Id = sd.FieldTruck  
GROUP BY sd.shiftid, t.FieldId)   
  
SELECT  
siteflag,  
a.shiftid,  
TruckId,  
[Tons] AS TotalMaterialDelivered  
FROM [chi].[CONOPS_CHI_SHIFT_INFO_V] a  
LEFT JOIN CTE b on a.SHIFTID = b.shiftid  
WHERE TruckId IS NOT NULL  
  
  
  
