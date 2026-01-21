CREATE VIEW [cer].[CONOPS_CER_EQMT_SHOVEL_HOURLY_TOTALMATERIALMINED_DUMPTIME_V] AS
  
  
  
  
--select * from [cer].[CONOPS_CER_EQMT_SHOVEL_HOURLY_TOTALMATERIALMINED_DUMPTIME_V]  
CREATE VIEW [cer].[CONOPS_CER_EQMT_SHOVEL_HOURLY_TOTALMATERIALMINED_DUMPTIME_V]  
AS  
  
SELECT    
sdps.shiftid,  
sdps.ShovelId,   
sdps.shiftdumptime,  
sdps.NrDumps,  
ISNULL(SUM(TotalMaterial), 0) AS TotalMaterialMoved,  
ISNULL(SUM(TotalMaterialMined), 0) AS TotalMaterialMined  
  
FROM (  
SELECT    
shiftid,  
shiftdumptime,  
ShovelId,   
SUM(LfTons) AS TotalMaterial,  
SUM(CASE WHEN dumps.[Load] IN (0,1,2,3,4,5,6,7,8,9,10,11,12,13,15,16,17,23,31,32,34,36,37,38,39) THEN LfTons ELSE 0 END) AS TotalMaterialMined,  
COUNT(LfTons) AS NrDumps,  
CASE WHEN loc IN ('MILLCHAN','HIDRO-C1','MILLCRUSH1','MILLCRUSH2','MILLSTK3-C2') THEN SUM(LfTons) ELSE 0 END AS MillOre,  
CASE WHEN loc NOT IN ('MILLCHAN','HIDRO-C1','MILLCRUSH1','MILLCRUSH2','MILLSTK3-C2','HIDROCHAN') AND LEFT(loc,1)<>'S' AND LEFT(loc,3)<>'DIN' AND LEFT(loc,3)<>'P1X' AND LEFT(loc,3)<>'P4B' AND LEFT(loc,5)<>'INPIT' THEN SUM(LfTons) ELSE 0 END AS Waste,  
CASE WHEN loc LIKE 'P1X%' OR loc LIKE 'P4B%' THEN SUM(LfTons) ELSE 0 END AS ROM,  
CASE WHEN loc IN ('HIDROCHAN') THEN SUM(LfTons) ELSE 0 END AS CrushedLeach,  
CASE WHEN loc IN ('MILLCHAN','HIDRO-C1','MILLCRUSH1','MILLCRUSH2','MILLSTK3-C2','HIDROCHAN') THEN SUM(LfTons) ELSE 0 END AS TotalDeliveredToCrushers,  
CASE WHEN (left(loc,1) ='S' or left(loc,3) ='DIN') AND right(loc,2) IN ('C1','C2','CL') THEN SUM(LfTons) ELSE 0 END AS TotalStockedMaterial  
FROM (  
SELECT      
sd.ShiftId,  
dateadd(second,sd.fieldtimedump,si.shiftstartdatetime) as shiftdumptime ,  
s.FieldId AS [ShovelId],  
enum.Idx AS [Load],  
( SELECT TOP 1 FieldId FROM cer.shift_loc WITH (NOLOCK) WHERE shift_loc_id = sd.FieldLoc ) AS loc,  
sd.FieldLsizetons AS [LfTons],  
sd.FieldTimedump  
FROM cer.shift_dump_v sd WITH (NOLOCK)  
LEFT JOIN cer.shift_loc sl WITH (NOLOCK) ON sl.shift_loc_id = sd.FieldLoc  
LEFT JOIN cer.shift_eqmt s WITH (NOLOCK) ON s.shift_eqmt_id = sd.FieldExcav  
LEFT JOIN cer.enum enum WITH (NOLOCK) ON sd.FieldLoad = enum.enum_id  
LEFT JOIN (  
SELECT shiftid, ShiftStartDateTime,LEAD(ShiftStartDateTime)   
OVER ( ORDER BY shiftid ) AS ShiftEndDateTime   
from cer.[shift_info] WITH (NOLOCK)) si ON sd.shiftid = si.shiftid  
) AS dumps  
WHERE ShovelId IS NOT NULL  
GROUP BY Shiftid, ShovelId, [Load],  [loc],shiftdumptime  
) AS sdps  
GROUP BY shiftid, ShovelId,sdps.shiftdumptime,sdps.NrDumps  
  
  
  
  
  
