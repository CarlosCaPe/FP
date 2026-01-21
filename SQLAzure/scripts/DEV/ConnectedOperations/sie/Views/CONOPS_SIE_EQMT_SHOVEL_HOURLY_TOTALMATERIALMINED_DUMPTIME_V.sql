CREATE VIEW [sie].[CONOPS_SIE_EQMT_SHOVEL_HOURLY_TOTALMATERIALMINED_DUMPTIME_V] AS
  
  
--select * from [sie].[CONOPS_SIE_EQMT_SHOVEL_HOURLY_TOTALMATERIALMINED_DUMPTIME_V]  
CREATE VIEW [sie].[CONOPS_SIE_EQMT_SHOVEL_HOURLY_TOTALMATERIALMINED_DUMPTIME_V]  
AS  
  
WITH CTE AS (  
SELECT   
sd.shiftid,  
dateadd(second,sd.fieldtimedump,sinfo.shiftstartdatetime) as shiftdumptime ,  
s.FieldId AS [ShovelId],  
sum(t.FieldSize) AS TotalMaterialMoved,  
ssloc.FieldId AS [Location],  
CASE WHEN ssloc.FieldId LIKE '%W' THEN SUM(t.FieldSize) ELSE 0 END AS TotalWasteMoved,    
CASE WHEN sl.FieldId LIKE '%PB%' AND ssloc.FieldId LIKE '%W' THEN SUM(t.FieldSize) ELSE 0 END AS WasteMined,  
CASE WHEN ssloc.FieldId IN ('CR13909O', 'A-SIDE', 'B-SIDE') THEN SUM(t.FieldSize) ELSE 0 END AS TotalCrushedMillOre,   
CASE WHEN ssloc.FieldId LIKE 'STO%' AND sl.FieldId LIKE '%PB%' THEN SUM(t.FieldSize) ELSE 0 END AS StockpiledMillOre,  
CASE WHEN ssloc.FieldId IN ('CR13909O', 'A-SIDE', 'B-SIDE') AND sl.FieldId NOT LIKE '%PB%' THEN SUM(t.FieldSize) ELSE 0 END AS StockpileToCrusherOre,  --Total Mineral Mined  
CASE WHEN ssloc.FieldId IN ('CR13909O', 'A-SIDE', 'B-SIDE') AND sl.FieldId LIKE '%PB%' THEN SUM(t.FieldSize) ELSE 0 END AS PitToCrusherOre               
FROM sie.shift_dump sd WITH (NOLOCK)  
LEFT JOIN sie.shift_eqmt t WITH (NOLOCK)  
ON t.Id = sd.FieldTruck AND t.SHIFTID = sd.shiftid  
LEFT JOIN sie.shift_eqmt s WITH (NOLOCK)  
ON s.Id = sd.FieldExcav AND s.SHIFTID = sd.shiftid  
LEFT JOIN sie.shift_loc sl WITH (NOLOCK)  
ON sl.Id = sd.FieldBlast AND sl.SHIFTID = sd.shiftid  
LEFT JOIN sie.shift_loc ssloc WITH (NOLOCK)  
ON ssloc.Id = sd.FieldLoc AND ssloc.SHIFTID = sd.shiftid  
LEFT JOIN sie.enum enum WITH (NOLOCK) ON sd.FieldLoad = enum.enumtypeid and enum.ABBREVIATION = 'load'  
LEFT JOIN (  
   SELECT shiftid, ShiftStartDateTime,LEAD(ShiftStartDateTime)   
   OVER ( ORDER BY shiftid ) AS ShiftEndDateTime   
   from sie.[shift_info] WITH (NOLOCK)) sinfo ON sd.shiftid = sinfo.shiftid  
GROUP BY sd.shiftid,s.FieldId,ssloc.FieldId,sl.FieldId,sd.fieldtimedump,sinfo.shiftstartdatetime)  
  
SELECT    
sdps.shiftid,  
sdps.ShovelId AS ShovelId,   
sdps.shiftdumptime,  
NULLIF(SUM(sdps.TotalMaterialMoved), 0) AS TotalMaterialMoved,  
(NULLIF(SUM(sdps.PitToCrusherOre),0) + NULLIF(SUM(sdps.StockpiledMillOre),0) + NULLIF(SUM(sdps.WasteMined),0)) AS TotalMaterialMined  
FROM CTE AS sdps  
  
  
GROUP BY sdps.ShovelId, sdps.shiftid,sdps.shiftdumptime  
  
  
  
  
