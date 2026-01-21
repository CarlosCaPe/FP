CREATE VIEW [saf].[CONOPS_SAF_EQMT_TOTALMATERIALDELIVERED_V] AS
  
  
  
  
  
--select * from [saf].[CONOPS_SAF_EQMT_TOTALMATERIALDELIVERED_V]  
CREATE VIEW [saf].[CONOPS_SAF_EQMT_TOTALMATERIALDELIVERED_V]  
AS  
  
WITH CTE AS (  
SELECT   
sd.shiftid,  
t.FieldId AS [TruckId],  
SUM(sd.FieldLsizetons) AS [Tons]  
FROM saf.SHIFT_DUMP sd WITH (NOLOCK)   
LEFT JOIN saf.shift_eqmt t WITH (NOLOCK) ON t.Id = sd.FieldTruck  
GROUP BY sd.shiftid, t.FieldId)  
  
  
SELECT  
siteflag,  
a.shiftid,  
TruckId,  
Tons As TotalMaterialDelivered  
FROM [saf].[CONOPS_SAF_SHIFT_INFO_V] a  
LEFT JOIN CTE b on a.SHIFTID = b.shiftid  
WHERE TruckId IS NOT NULL  
  
  
  
  
