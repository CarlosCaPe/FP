CREATE VIEW [mor].[CONOPS_MOR_TONS_SNAPSHOT_V] AS



--select sum(totalmaterialmined) from [mor].[CONOPS_MOR_TONS_SNAPSHOT_V] where shiftid = '230524001' order by fieldtimedump desc

CREATE VIEW [mor].[CONOPS_MOR_TONS_SNAPSHOT_V]
AS


WITH ShiftDump AS (
SELECT   
sd.shiftid,
sd.utc_created_date as shiftdumptime ,
s.FieldId AS [ShovelId] ,
sd.FieldLsizetons AS [Tons] ,
sl.FieldId AS [Location] ,
slloc.FieldId AS [LoadLoc],
enum.[Description]
FROM mor.SHIFT_DUMP_V sd WITH (NOLOCK)
LEFT JOIN mor.shift_load sload ON sd.id = sload.FieldDumprec
LEFT JOIN mor.shift_eqmt s ON s.Id = sd.FieldExcav
LEFT JOIN mor.shift_loc sl ON sl.Id = sd.FieldLoc
LEFT JOIN mor.shift_loc slloc ON slloc.Id = sload.FieldLoc
LEFT JOIN mor.enum enum ON sd.FieldLoad = enum.Id
WHERE ( s.FieldId LIKE 'S%' OR s.FieldId IN ( 'L58', 'L59' ) )),


ShiftDumpPerShovel AS (
SELECT   
sd.shiftid,
sd.shiftdumptime,
sd.ShovelId ,
COUNT(sd.Tons) AS [NrDumps] ,
CASE WHEN sd.[Location] LIKE '%MFL' AND sd.LoadLoc NOT LIKE '%-MFL'
THEN SUM(sd.Tons) ELSE 0 END AS [TotalCrushedLeachMined] ,
CASE WHEN (sd.LoadLoc LIKE '%-MFL' OR sd.LoadLoc LIKE '%-MILL')
THEN SUM(sd.Tons) ELSE 0 END AS [TotalTransferOre] ,
CASE WHEN (sd.[Location] LIKE '%L4' OR
sd.[Location] LIKE '%W') AND
sd.LoadLoc NOT LIKE '%-MFL'  AND
sd.LoadLoc NOT LIKE '%-MILL'
THEN SUM(sd.Tons) ELSE 0 END AS [TotalWasteMined] ,
CASE WHEN sd.[Location] LIKE '%MIL%' AND 
sd.LoadLoc NOT LIKE '%-MILL'
THEN SUM(sd.Tons) ELSE 0 END AS [TotalMillOreMined] ,
CASE WHEN sd.[Location] NOT LIKE '%MFL' AND 
sd.[Location] NOT LIKE '%MIL%' AND
sd.[Location] NOT LIKE '%L4'  AND
sd.[Location] NOT LIKE '%W'  AND
sd.LoadLoc NOT LIKE '%-MFL'  AND
sd.LoadLoc NOT LIKE '%-MILL'
THEN SUM(sd.Tons) ELSE 0 END AS [TotalROMLeachMined] ,
CASE WHEN sd.[Location] LIKE 'C%MFL' OR 
sd.[Location] LIKE 'C%MIL'
THEN SUM(sd.Tons) ELSE 0 END AS [TotalDeliveredToCrushers]
FROM ShiftDump sd
GROUP BY sd.shiftid,
sd.ShovelId ,
sd.shiftdumptime,
sd.[Description] ,
sd.[Location],
sd.LoadLoc)

SELECT  
sdps.shiftid,
sdps.shiftdumptime,
sdps.ShovelId,
ISNULL(SUM(sdps.NrDumps), 0) AS [NrOfDumps] ,
( ISNULL(SUM(sdps.TotalMillOreMined), 0)
  + ISNULL(SUM(sdps.TotalROMLeachMined), 0)
  + ISNULL(SUM(sdps.TotalCrushedLeachMined), 0)
  + ISNULL(SUM(sdps.TotalWasteMined), 0) ) AS [TotalMaterialMined]  --TotalMaterialMined
FROM ShiftDumpPerShovel sdps
GROUP BY sdps.shiftid,sdps.shiftdumptime,sdps.ShovelId



