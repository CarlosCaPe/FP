CREATE VIEW [sie].[CONOPS_SIE_EQMT_TOTALMATERIALDELIVERED_V] AS
  
  
  
  
  
--select * from [sie].[CONOPS_SIE_EQMT_TOTALMATERIALDELIVERED_V]  
CREATE VIEW [sie].[CONOPS_SIE_EQMT_TOTALMATERIALDELIVERED_V]  
AS  
  
WITH CTE AS (  
SELECT   
sd.shiftid,  
t.FieldId AS [TruckId],  
SUM(sd.FieldLsizetons) AS [Tons]  
FROM SIE.SHIFT_DUMP sd WITH (NOLOCK)   
LEFT JOIN SIE.shift_eqmt t WITH (NOLOCK) ON t.Id = sd.FieldTruck  
GROUP BY sd.shiftid, t.FieldId)  
  
  
SELECT  
siteflag,  
a.shiftid,  
TruckId,  
Tons As TotalMaterialDelivered  
FROM [sie].[CONOPS_SIE_SHIFT_INFO_V] a  
LEFT JOIN CTE b on a.SHIFTID = b.shiftid  
WHERE TruckId IS NOT NULL  
  
  
  
  
