CREATE VIEW [cli].[CONOPS_CLI_EQMT_SHOVEL_HOURLY_TOTALMATERIALMINED_DUMPTIME_V] AS
  
  
--select * from [cli].[CONOPS_CLI_EQMT_SHOVEL_HOURLY_TOTALMATERIALMINED_DUMPTIME_V]  
CREATE VIEW [cli].[CONOPS_CLI_EQMT_SHOVEL_HOURLY_TOTALMATERIALMINED_DUMPTIME_V]  
AS  
  
  
WITH ShiftDump AS (  
SELECT  
sd.shiftid,  
dateadd(second,sd.fieldtimedump,sinfo.shiftstartdatetime) as shiftdumptime,  
s.FieldId AS [ShovelId],  
t.FieldSize AS [Tons],  
ssloc.FieldId AS [Location],  
sl.FieldId AS DumpLocation,  
enum.[Description] AS MaterialType,  
enum.Idx AS [Load]  
FROM cli.shift_dump sd WITH (NOLOCK)  
LEFT JOIN cli.shift_eqmt t WITH (NOLOCK)  
ON t.Id = sd.FieldTruck AND t.SHIFTID = sd.shiftid  
LEFT JOIN cli.shift_eqmt s WITH (NOLOCK)  
ON s.Id = sd.FieldExcav AND s.SHIFTID = sd.shiftid  
LEFT JOIN cli.shift_loc sl WITH (NOLOCK)  
ON sl.Id = sd.FieldBlast AND sl.SHIFTID = sd.shiftid  
LEFT JOIN cli.shift_loc ssloc WITH (NOLOCK)  
ON ssloc.Id = sd.FieldLoc AND ssloc.SHIFTID = sd.shiftid  
LEFT JOIN cli.enum enum WITH (NOLOCK) ON sd.FieldLoad = enum.Id  
LEFT JOIN (  
SELECT shiftid, ShiftStartDateTime,LEAD(ShiftStartDateTime)   
OVER ( ORDER BY shiftid ) AS ShiftEndDateTime   
from cli.[shift_info] WITH (NOLOCK)) sinfo ON sd.shiftid = sinfo.shiftid),  
  
ShiftPit AS (  
SELECT   
sd.shiftid,  
sr.FieldId AS [Region],  
ssloc.FieldId AS [Dump]  
FROM cli.shift_dump sd WITH (NOLOCK)  
LEFT JOIN cli.shift_loc sl WITH (NOLOCK)  
ON sl.Id = sd.FieldBlast AND sl.SHIFTID = sd.shiftid  
LEFT JOIN cli.shift_loc sr WITH (NOLOCK)  
ON sr.Id = sl.FieldRegion AND sr.SHIFTID = sd.shiftid  
LEFT JOIN cli.shift_loc ssloc WITH (NOLOCK)  
ON ssloc.Id = sd.FieldLoc AND ssloc.SHIFTID = sd.shiftid),     
     
ShiftDumpPerShovel AS (  
SELECT ShovelId, shiftid,  
shiftdumptime,  
SUM(Tons) AS TotalMaterial,  
(CASE WHEN Location LIKE '%CRUSHER%' AND   
(MaterialType LIKE '%H01%' OR MaterialType LIKE '%H02%' OR MaterialType LIKE '%H03%'  
OR MaterialType LIKE '%H04%' OR MaterialType LIKE '%H05%'  
OR MaterialType LIKE '%L01%' OR MaterialType LIKE '%L02%'  
OR MaterialType LIKE '%L03%' OR MaterialType LIKE '%L04%'  
OR MaterialType LIKE '%L05%')  
THEN SUM(Tons) ELSE 0 END) AS TotalExpitOre,  
(CASE WHEN (Location LIKE '%MCN%' OR Location LIKE '%INPIT%' OR Location LIKE '%IN%PIT%'  
OR Location LIKE '%ROAD%' OR MaterialType LIKE '%SNOW%') AND  
(MaterialType LIKE '%W01%' OR MaterialType LIKE '%W02%' OR MaterialType LIKE '%W03%'   
OR MaterialType LIKE '%W04%' OR MaterialType LIKE '%W05%')  
THEN SUM(Tons) ELSE 0 END) AS TotalWaste,  
(CASE WHEN (Location LIKE '%SLS_%' OR Location LIKE '%CSP_%' OR Location LIKE '%N40%'  
OR Location LIKE '%DOSS%') AND  
(MaterialType LIKE '%H01%' OR MaterialType LIKE '%H02%' OR MaterialType LIKE '%H03%'  
OR MaterialType LIKE '%H04%' OR MaterialType LIKE '%H05%'  
OR MaterialType LIKE '%L01%' OR MaterialType LIKE '%L02%'  
OR MaterialType LIKE '%L03%' OR MaterialType LIKE '%L04%'  
OR MaterialType LIKE '%L05%')  
THEN SUM(Tons) ELSE 0 END) AS TotalStockpiled,  
(CASE WHEN load IN (0) AND Location NOT LIKE ('ROADFILL%') THEN SUM(Tons) ELSE 0 END) AS TotalExpit,  
(CASE WHEN load IN (0) AND Location LIKE ('ROADFILL%') THEN SUM(Tons) ELSE 0 END) AS TotalInpit,  
(CASE WHEN load IN (0) THEN SUM(Tons) ELSE 0 END) AS TotalLeach,  
(CASE WHEN Location LIKE 'CRUSHER%' THEN SUM(Tons) ELSE 0 END) AS OreRehandletoCrusher,  
(CASE WHEN Location LIKE 'CRUSHER%' THEN SUM(Tons) ELSE 0 END) AS TotalCrushedMillOre,  
(CASE WHEN load IN (0) AND Location LIKE 'CRUSHER%' THEN SUM(Tons) ELSE 0 END) AS ExpitOreToCrusher  
FROM ShiftDump  
GROUP BY ShovelId, Location, MaterialType, load, shiftid,shiftdumptime),  
      
ShovelByRegion AS (   
SELECT DISTINCT dump.shiftid,loc.region, dump.ShovelId  
FROM ShiftDump dump   
INNER JOIN ShiftPit loc ON Dump.Location = loc.[Dump] AND dump.shiftid = loc.SHIFTID)  
      
SELECT   
sbr.ShovelId,  
sdps.shiftid AS shiftid,  
sdps.shiftdumptime,  
ISNULL(SUM(sdps.TotalMaterial), 0) AS TotalMaterialMin