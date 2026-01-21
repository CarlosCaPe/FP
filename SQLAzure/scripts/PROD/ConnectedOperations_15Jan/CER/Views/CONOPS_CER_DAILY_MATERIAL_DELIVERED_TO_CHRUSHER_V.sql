CREATE VIEW [CER].[CONOPS_CER_DAILY_MATERIAL_DELIVERED_TO_CHRUSHER_V] AS




  
  
  
  
  
--select * from [cer].[CONOPS_CER_DAILY_MATERIAL_DELIVERED_TO_CHRUSHER_V] WITH (NOLOCK) where shiftflag = 'curr'  
CREATE VIEW [cer].[CONOPS_CER_DAILY_MATERIAL_DELIVERED_TO_CHRUSHER_V]  
AS  
  
  
WITH CTE AS (  
SELECT  
dumps.shiftid,  
s.FieldId AS Loc,  
--SSE.[FieldSize]  AS [LfTons]  
dumps.FieldLsizetons  AS [LfTons]  
FROM cer.shift_dump_v dumps WITH (NOLOCK)  
LEFT JOIN cer.shift_loc s ON shift_loc_id = dumps.FieldLoc  
LEFT JOIN cer.shift_eqmt SSE ON SSE.shift_eqmt_id = dumps.FieldTruck AND SSE.ShiftId=dumps.ShiftId  
LEFT JOIN cer.Enum enums on enums.enum_Id=dumps.FieldLoad AND enums.Idx NOT IN (26,27,28,29,30)  
WHERE s.FieldId in ('MILLCHAN','MILLCRUSH1','MILLCRUSH2')),  
  
MaterialDelivered AS (  
SELECT  
shiftid,   
[loc] AS CrusherLoc,    
CASE WHEN loc in ('MILLCHAN','HIDRO-C1','MILLCRUSH1','MILLCRUSH2') THEN SUM(lfTons) ELSE 0 END AS MillOreDeliveredToCrusher,  
CASE WHEN loc in ('HIDROCHAN') THEN SUM(lfTons) ELSE 0 END AS MflDeliveredToCrusher,  
COUNT(lfTons) AS NrDumps  
FROM CTE  
GROUP BY [loc],shiftid)  
  
SELECT   
a.shiftflag,  
a.siteflag,  
a.shiftid,  
b.CrusherLoc AS [Name],  
ROUND(COALESCE (b.MillOreDeliveredToCrusher,0)/1000.00,1) AS MillOreActual,  
CASE WHEN b.CrusherLoc <> 'HIDROCHAN'  
      THEN ROUND((COALESCE(c.[Target], 0) * (FLOOR(a.ShiftDuration / 3600) / 12.00 )) / 1000.00, 1)  
      ELSE 0  
       END AS MillOreTarget,  
CASE WHEN b.CrusherLoc <> 'HIDROCHAN'  
      THEN ROUND(COALESCE(c.[Target], 0) / 1000.00, 1)  
      ELSE 0  
       END AS MillOreShiftTarget,  
ROUND(COALESCE (b.MflDeliveredToCrusher,0)/1000.00,1) AS LeachActual,  
CASE WHEN b.CrusherLoc = 'HIDROCHAN'  
      THEN ROUND((COALESCE(c.[Target], 0) * (FLOOR(a.ShiftDuration / 3600) / 12.00 )) / 1000.00, 1)  
      ELSE 0  
       END AS LeachTarget,  
CASE WHEN b.CrusherLoc = 'HIDROCHAN'  
      THEN ROUND(COALESCE(c.[Target], 0) / 1000.00, 1)  
      ELSE 0  
       END AS LeachShiftTarget,  
NrDumps AS TotalNrDumps  
FROM [cer].[CONOPS_CER_EOS_SHIFT_INFO_V] a  
LEFT JOIN MaterialDelivered b on a.shiftid = b.shiftid  
LEFT JOIN [cer].[CONOPS_CER_DAILY_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V] c on a.shiftid = c.shiftid AND b.CrusherLoc = c.[Location]  
  
  



