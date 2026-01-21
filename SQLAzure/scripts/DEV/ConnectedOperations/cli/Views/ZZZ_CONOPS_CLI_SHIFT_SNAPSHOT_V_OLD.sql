CREATE VIEW [cli].[ZZZ_CONOPS_CLI_SHIFT_SNAPSHOT_V_OLD] AS





CREATE VIEW [cli].[CONOPS_CLI_SHIFT_SNAPSHOT_V_OLD]
AS


WITH ShiftDump AS (
SELECT 
sd.shiftid,
dateadd(second,sd.fieldtimedump,sinfo.shiftstartdatetime) as shiftdumptime ,
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
LEFT JOIN cli.enum enum ON sd.FieldLoad = enum.Id
LEFT JOIN (
SELECT shiftid, ShiftStartDateTime,LEAD(ShiftStartDateTime) 
OVER ( ORDER BY shiftid ) AS ShiftEndDateTime 
from [cli].[shift_info]) sinfo ON sd.shiftid = sinfo.shiftid),

ShiftPit AS (
SELECT 
sd.shiftid,
sr.FieldId AS [Region],
s.FieldId AS [ShovelId],
t.FieldSize AS [Tons],
sl.FieldId AS [Location],
ssloc.FieldId AS [Dump],
enum.[Description] AS [Description],
enum.Id AS [enumId]
FROM cli.shift_dump sd WITH (NOLOCK)
LEFT JOIN cli.shift_eqmt t WITH (NOLOCK)
ON t.Id = sd.FieldTruck AND t.SHIFTID = sd.shiftid
LEFT JOIN cli.shift_eqmt s WITH (NOLOCK)
ON s.Id = sd.FieldExcav AND s.SHIFTID = sd.shiftid
LEFT JOIN cli.shift_loc sl WITH (NOLOCK)
ON sl.Id = sd.FieldBlast AND sl.SHIFTID = sd.shiftid
LEFT JOIN cli.shift_loc sr WITH (NOLOCK)
ON sr.Id = sl.FieldRegion AND sr.SHIFTID = sd.shiftid
LEFT JOIN cli.shift_loc ssloc WITH (NOLOCK)
ON ssloc.Id = sd.FieldLoc AND ssloc.SHIFTID = sd.shiftid
LEFT JOIN cli.enum enum WITH (NOLOCK) ON enum.Id = ssloc.FieldUnit ),   
   
ShiftDumpPerShovel AS (
SELECT ShovelId, shiftid,shiftdumptime,
COUNT(Tons) AS NrDumps, 
SUM(Tons) AS TotalMaterial
FROM ShiftDump
GROUP BY ShovelId, Location, MaterialType, load, shiftid,shiftdumptime),
    
ShovelByRegion AS ( 
SELECT DISTINCT loc.region, dump.ShovelId
FROM ShiftDump dump 
INNER JOIN ShiftPit loc ON Dump.Location = loc.[Dump])
    
SELECT 
shiftid,
sbr.ShovelId,
sdps.shiftdumptime,
NULLIF(CAST(SUM(sdps.NrDumps) AS INTEGER), 0) AS NrOfDumps,
NULLIF(SUM(sdps.TotalMaterial), 0) AS TotalMaterialMined
FROM ShovelByRegion sbr
LEFT JOIN ShiftDumpPerShovel sdps ON sdps.ShovelId = sbr.ShovelId

GROUP BY sbr.ShovelId,sdps.shiftdumptime,shiftid



