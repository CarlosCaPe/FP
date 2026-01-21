CREATE VIEW [TYR].[CONOPS_TYR_EQMT_TOTALMATERIALDELIVERED_V] AS



--select * from [tyr].[CONOPS_TYR_EQMT_TOTALMATERIALDELIVERED_V]  
CREATE VIEW [TYR].[CONOPS_TYR_EQMT_TOTALMATERIALDELIVERED_V]  
AS  
  
/*WITH CTE AS (  
SELECT   
dumps.shiftid,  
SSE.fieldid AS Truckid,  
SSE.[FieldSize] AS [Tons]  
FROM mor.shift_dump_v dumps WITH (NOLOCK)  
LEFT JOIN mor.shift_eqmt SSE WITH (NOLOCK) ON SSE.Id = dumps.FieldTruck AND SSE.ShiftId = dumps.[OrigShiftid]  
LEFT JOIN mor.shift_loc loc WITH  (NOLOCK)  ON loc.Id = dumps.FieldLoc  
LEFT JOIN mor.Enum enums WITH (nolock)  ON enums.Id = dumps.FieldLoad  
WHERE enums.Idx NOT IN ( 26, 27, 28, 29, 30 )  
AND loc.FieldId IN ( 'C2MIL', 'C3MIL', 'C2MFL', 'C3MFL' ))*/  
  
WITH CTE AS (  
SELECT   
sd.shiftid,  
t.FieldId AS [TruckId],  
SUM(sd.FieldLsizetons) AS [Tons]  
FROM [tyr].shift_dump_v sd WITH (NOLOCK)  
LEFT JOIN [tyr].shift_eqmt t WITH (NOLOCK) ON t.Id = sd.FieldTruck  
GROUP BY sd.shiftid, t.FieldId)  
  
  
SELECT  
siteflag,  
a.shiftid,  
TruckId,  
Tons As TotalMaterialDelivered  
FROM [tyr].[CONOPS_TYR_SHIFT_INFO_V] a  
LEFT JOIN CTE b on a.SHIFTID = b.shiftid  
WHERE TruckId IS NOT NULL  
  
  
  
  

