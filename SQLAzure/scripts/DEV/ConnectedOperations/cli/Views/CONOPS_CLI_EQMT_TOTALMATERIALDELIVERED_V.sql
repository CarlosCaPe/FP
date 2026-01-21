CREATE VIEW [cli].[CONOPS_CLI_EQMT_TOTALMATERIALDELIVERED_V] AS
  
   
--select * from [cli].[CONOPS_CLI_EQMT_TOTALMATERIALDELIVERED_V]    
CREATE VIEW [cli].[CONOPS_CLI_EQMT_TOTALMATERIALDELIVERED_V]    
AS    
    
/*WITH CTE AS (    
SELECT      
dumps.shiftid,    
t.FieldId AS [TruckId],    
dumps.FieldLsizetons AS [Tons]    
FROM [cli].SHIFT_DUMP dumps  WITH (NOLOCK)    
LEFT JOIN [cli].Enum enums WITH (NOLOCK) on enums.Id=dumps.FieldLoad     
LEFT JOIN [cli].shift_loc loc WITH (NOLOCK) ON loc.Id = dumps.FieldLoc     
LEFT JOIN [cli].shift_eqmt t ON t.Id = dumps.FieldTruck    
WHERE enums.Idx NOT IN (26,27,28,29,30)    
AND (loc.FieldId IN ('CRUSHER 1')))*/    
    
    
WITH CTE AS (    
SELECT     
sd.shiftid,    
t.FieldId AS [TruckId],    
SUM(sd.FieldLsizetons) AS [Tons]    
FROM cli.SHIFT_DUMP sd WITH (NOLOCK)     
LEFT JOIN cli.shift_eqmt t WITH (NOLOCK) ON t.Id = sd.FieldTruck    
GROUP BY sd.shiftid, t.FieldId)    
    
    
SELECT    
siteflag,    
a.shiftid,    
TruckId,    
Tons As TotalMaterialDelivered    
FROM [cli].[CONOPS_CLI_SHIFT_INFO_V] a    
LEFT JOIN CTE b on a.SHIFTID = b.shiftid    
WHERE TruckId IS NOT NULL    
    
    
    
    
  
  
