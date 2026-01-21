CREATE VIEW [MOR].[CONOPS_MOR_EQMT_TOTALMATERIALDELIVERED_V] AS
  
  
  
  
  
--select * from [mor].[CONOPS_MOR_EQMT_TOTALMATERIALDELIVERED_V]  
CREATE VIEW [mor].[CONOPS_MOR_EQMT_TOTALMATERIALDELIVERED_V]  
AS  
  
  
WITH CTE AS (  
SELECT   
sd.shiftid,  
t.FieldId AS [TruckId],  
SUM(sd.FieldLsizetons) AS [Tons]  
FROM mor.shift_dump_v sd WITH (NOLOCK)  
LEFT JOIN mor.shift_eqmt t WITH (NOLOCK) ON t.Id = sd.FieldTruck  
GROUP BY sd.shiftid, t.FieldId)  
  
  
SELECT  
siteflag,  
a.shiftid,  
TruckId,  
Tons As TotalMaterialDelivered  
FROM [mor].[CONOPS_MOR_SHIFT_INFO_V] a  
LEFT JOIN CTE b on a.SHIFTID = b.shiftid  
WHERE TruckId IS NOT NULL  
  
  
  
  
