CREATE VIEW [MOR].[CONOPS_MOR_SHIFT_V] AS




CREATE VIEW [mor].[CONOPS_MOR_SHIFT_V]
AS

SELECT a.shiftflag,a.siteflag,a.shiftid,b.shovelid,b.tons,b.location,b.loadloc,b.description,b.mineloc
FROM [dbo].[SHIFT_INFO_V] a (NOLOCK)
LEFT JOIN (
SELECT sdm.shiftid,
s.FieldId AS [ShovelId] ,
sdm.FieldLsizetons AS [Tons] ,
sl.FieldId AS [Location],
slloc.FieldId AS [LoadLoc],
enum.[Description],
CASE WHEN sl.FieldId LIKE '%MFL' AND sl.FieldId NOT LIKE '%-MFL' THEN 'CrushedLeach' 
WHEN sl.FieldId LIKE '%MIL%' AND sl.FieldId NOT LIKE '%-MILL' THEN 'MillOre'
WHEN (sl.FieldId LIKE '%L4' OR
sl.FieldId LIKE '%W') AND slloc.FieldId NOT LIKE '%-MFL'AND slloc.FieldId NOT LIKE '%-MILL' THEN 'Waste'
WHEN sl.FieldId NOT LIKE '%MFL' AND 
sl.FieldId NOT LIKE '%MIL%' AND
sl.FieldId NOT LIKE '%L4'AND
sl.FieldId NOT LIKE '%W'AND
slloc.FieldId NOT LIKE '%-MFL'AND
slloc.FieldId NOT LIKE '%-MILL' THEN 'ROMLeach'
WHEN sl.FieldId LIKE 'C%MFL' OR 
sl.FieldId LIKE 'C%MIL' THEN 'DeliveredToCrushers'
WHEN slloc.FieldId LIKE '%-MFL' OR slloc.FieldId LIKE '%-MILL' THEN 'TransferOre'
ELSE NULL END AS MineLoc
FROM mor.shift_dump_v sdm WITH (NOLOCK)
LEFT JOIN mor.shift_load (NOLOCK) sload ON sdm.id = sload.FieldDumprec
LEFT JOIN mor.shift_eqmt (NOLOCK) s ON s.Id = sdm.FieldExcav
LEFT JOIN mor.shift_loc (NOLOCK) sl ON sl.Id = sdm.FieldLoc
LEFT JOIN mor.shift_loc (NOLOCK) slloc ON slloc.Id = sload.FieldLoc
LEFT JOIN mor.enum (NOLOCK) enum ON sdm.FieldLoad = enum.Id
WHERE  s.FieldId LIKE 'S%'
OR s.FieldId IN ( 'L58', 'L59' )) b on a.shiftid = b.shiftid
--order by sdm.shiftid desc
LEFT JOIN (
SELECT pe.FieldId AS [ShovelId]
FROM mor.pit_excav pe WITH (NOLOCK)
INNER JOIN mor.pit_loc ppl WITH (NOLOCK) ON ppl.Id = pe.FieldLoc
INNER JOIN mor.pit_loc pplr WITH (NOLOCK) ON pplr.Id = ppl.FieldRegion
UNION
SELECT DISTINCT
sd.ShovelId
FROM (
SELECT 
s.FieldId AS [ShovelId] ,
sd.FieldLsizetons AS [Tons] ,
sl.FieldId AS [Location] ,
slloc.FieldId AS [LoadLoc],
enum.[Description]
FROM mor.shift_dump_v sd WITH (NOLOCK)
LEFT JOIN mor.shift_load (NOLOCK) sload ON sd.id = sload.FieldDumprec
LEFT JOIN mor.shift_eqmt (NOLOCK) s ON s.Id = sd.FieldExcav
LEFT JOIN mor.shift_loc (NOLOCK) sl ON sl.Id = sd.FieldLoc
LEFT JOIN mor.shift_loc (NOLOCK) slloc ON slloc.Id = sload.FieldLoc
LEFT JOIN mor.enum (NOLOCK) enum ON sd.FieldLoad = enum.Id
WHERE 
s.FieldId LIKE 'S%'
OR s.FieldId IN ( 'L58', 'L59' )) sd ) sbr
on b.shovelid = sbr.shovelid

