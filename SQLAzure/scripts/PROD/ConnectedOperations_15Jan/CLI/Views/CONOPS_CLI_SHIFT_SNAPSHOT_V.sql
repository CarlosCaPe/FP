CREATE VIEW [CLI].[CONOPS_CLI_SHIFT_SNAPSHOT_V] AS



CREATE VIEW [cli].[CONOPS_CLI_SHIFT_SNAPSHOT_V]
AS


WITH ShiftDump AS ( 
SELECT  
sd.shiftid,
dateadd(second,sd.fieldtimedump,sinfo.shiftstartdatetime) as shiftdumptime ,
s.FieldId AS [ShovelId] ,
sd.FIELDLSIZEDB AS [Tons] ,
sl.FieldId AS [Location] ,
enum.[Description] ,
enum.Idx AS [Load]
FROM cli.shift_dump sd WITH ( NOLOCK )
LEFT JOIN cli.shift_eqmt s WITH ( NOLOCK ) ON s.Id = sd.FieldExcav
LEFT JOIN cli.shift_loc sl WITH ( NOLOCK ) ON sl.Id = sd.FieldLoc
LEFT JOIN cli.Enum enum WITH ( NOLOCK ) ON sd.FieldLoad = enum.Id
LEFT JOIN (
SELECT shiftid, ShiftStartDateTime,LEAD(ShiftStartDateTime) 
OVER ( ORDER BY shiftid ) AS ShiftEndDateTime 
from [cli].[shift_info]) sinfo ON sd.shiftid = sinfo.shiftid
),

ShiftDumpPerShovel AS ( 
SELECT   
sd.shiftid,
sd.ShovelId ,
sd.shiftdumptime,
COUNT(sd.Tons) AS [NrDumps] ,
SUM(sd.Tons) AS TotalMaterial 
  FROM     ShiftDump sd
  GROUP BY sd.shiftid,sd.ShovelId ,
sd.[Location] ,
sd.[Description] ,
sd.[Load],
sd.shiftdumptime
),

ShovelByRegion AS ( 
SELECT   
pplr.FieldId AS [Region] ,
pe.FieldId AS [ShovelId]
FROM cli.pit_excav pe WITH ( NOLOCK )
INNER JOIN cli.pit_loc ppl WITH ( NOLOCK ) ON ppl.Id = pe.FieldLoc
INNER JOIN cli.pit_loc pplr WITH ( NOLOCK ) ON pplr.Id = ppl.FieldRegion
)

SELECT  sdps.shiftid,
		sbr.ShovelId ,
		sdps.shiftdumptime,
        ISNULL(SUM(sdps.NrDumps), 0) AS [NrOfDumps] ,
        ISNULL(SUM(sdps.TotalMaterial), 0) AS [TotalMaterialMined] 
FROM    ShovelByRegion sbr
        LEFT JOIN ShiftDumpPerShovel sdps ON sdps.ShovelId = sbr.ShovelId
WHERE sdps.shiftid IS NOT NULL
GROUP BY sdps.shiftid,
		sbr.ShovelId ,
		sdps.shiftdumptime

