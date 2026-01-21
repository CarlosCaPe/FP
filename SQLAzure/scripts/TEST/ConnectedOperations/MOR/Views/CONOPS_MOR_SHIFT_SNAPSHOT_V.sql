CREATE VIEW [MOR].[CONOPS_MOR_SHIFT_SNAPSHOT_V] AS




CREATE VIEW [mor].[CONOPS_MOR_SHIFT_SNAPSHOT_V]
AS


WITH    ShiftDump
AS ( SELECT   
			sd.shiftid,
			dateadd(second,sd.fieldtimedump,sinfo.shiftstartdatetime) as shiftdumptime ,
			s.FieldId AS [ShovelId] ,
            sd.FieldLsizetons AS [Tons] ,
            sl.FieldId AS [Location] ,
            slloc.FieldId AS [LoadLoc],
            enum.[Description]
   FROM     mor.shift_dump_v sd WITH (NOLOCK)
            LEFT JOIN mor.shift_load sload ON sd.id = sload.FieldDumprec
            LEFT JOIN mor.shift_eqmt s ON s.Id = sd.FieldExcav
            LEFT JOIN mor.shift_loc sl ON sl.Id = sd.FieldLoc
            LEFT JOIN mor.shift_loc slloc ON slloc.Id = sload.FieldLoc
            LEFT JOIN mor.enum enum ON sd.FieldLoad = enum.Id
			LEFT JOIN (
			SELECT shiftid, ShiftStartDateTime,LEAD(ShiftStartDateTime) 
			OVER ( ORDER BY shiftid ) AS ShiftEndDateTime 
			from [mor].[shift_info]) sinfo ON sd.shiftid = sinfo.shiftid
   WHERE    ( s.FieldId LIKE 'S%'
                  OR s.FieldId IN ( 'L58', 'L59' )
                )
				
 ),
 
    ShiftDumpPerShovel
      AS ( SELECT   
			sd.shiftid,
			sd.shiftdumptime,
			sd.ShovelId ,
            COUNT(sd.Tons) AS [NrDumps] ,
            CASE WHEN sd.[Location] LIKE '%MFL' AND sd.LoadLoc NOT LIKE '%-MFL'
                 THEN SUM(sd.Tons)
                 ELSE 0
            END AS [TotalCrushedLeachMined] ,
            CASE WHEN (sd.LoadLoc LIKE '%-MFL' OR sd.LoadLoc LIKE '%-MILL')
                 THEN SUM(sd.Tons)
                 ELSE 0
            END AS [TotalTransferOre] ,
            CASE WHEN (sd.[Location] LIKE '%L4' OR
											             sd.[Location] LIKE '%W') AND
            	         sd.LoadLoc NOT LIKE '%-MFL'  AND
            	         sd.LoadLoc NOT LIKE '%-MILL'
                 THEN SUM(sd.Tons)
                 ELSE 0
            END AS [TotalWasteMined] ,
            CASE WHEN sd.[Location] LIKE '%MIL%' AND 
											             sd.LoadLoc NOT LIKE '%-MILL'
                 THEN SUM(sd.Tons)
                 ELSE 0
            END AS [TotalMillOreMined] ,
            CASE WHEN sd.[Location] NOT LIKE '%MFL' AND 
            	         sd.[Location] NOT LIKE '%MIL%' AND
            	         sd.[Location] NOT LIKE '%L4'  AND
            	         sd.[Location] NOT LIKE '%W'  AND
            	         sd.LoadLoc NOT LIKE '%-MFL'  AND
            	         sd.LoadLoc NOT LIKE '%-MILL'
                 THEN SUM(sd.Tons)
                 ELSE 0
            END AS [TotalROMLeachMined] ,
            CASE WHEN sd.[Location] LIKE 'C%MFL' OR 
            	         sd.[Location] LIKE 'C%MIL'
                 THEN SUM(sd.Tons)
                 ELSE 0
            END AS [TotalDeliveredToCrushers]
   FROM     ShiftDump sd
   GROUP BY sd.shiftid,
			sd.ShovelId ,
			sd.shiftdumptime,
            sd.[Description] ,
            sd.[Location],
            sd.LoadLoc
 ),
 
    ShovelByRegion
      AS ( SELECT   pe.FieldId AS [ShovelId]
   FROM     mor.pit_excav pe WITH (NOLOCK)
            INNER JOIN mor.pit_loc ppl WITH (NOLOCK) ON ppl.Id = pe.FieldLoc
            INNER JOIN mor.pit_loc pplr WITH (NOLOCK) ON pplr.Id = ppl.FieldRegion
   UNION
   SELECT DISTINCT
            sd.ShovelId
   FROM     ShiftDump sd
 )
 
 
SELECT  
sdps.shiftid,
sbr.ShovelId ,
sdps.shiftdumptime,
ISNULL(SUM(sdps.NrDumps), 0) AS [NrOfDumps] ,
( ISNULL(SUM(sdps.TotalMillOreMined), 0)
  + ISNULL(SUM(sdps.TotalROMLeachMined), 0)
  + ISNULL(SUM(sdps.TotalCrushedLeachMined), 0)
  + ISNULL(SUM(sdps.TotalWasteMined), 0) ) AS [TotalMaterialMined]  --TotalMaterialMined
FROM    ShovelByRegion sbr
LEFT JOIN ShiftDumpPerShovel sdps ON sdps.ShovelId = sbr.ShovelId
--WHERE sdps.shiftid = '221213001'

GROUP BY sbr.ShovelId,sdps.shiftid,sdps.shiftdumptime
--ORDER BY sbr.ShovelId;

