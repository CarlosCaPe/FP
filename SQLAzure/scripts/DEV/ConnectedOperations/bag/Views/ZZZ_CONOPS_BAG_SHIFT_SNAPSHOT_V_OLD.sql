CREATE VIEW [bag].[ZZZ_CONOPS_BAG_SHIFT_SNAPSHOT_V_OLD] AS



CREATE VIEW [bag].[CONOPS_BAG_SHIFT_SNAPSHOT_V_OLD]
AS


SELECT  
shiftid,
ShovelId, 
shiftdumptime,
NULLIF(CAST(SUM(NrDumps) AS INTEGER) , 0) AS NrOfDumps,
NULLIF(SUM(INPIT) + SUM(EXPIT) + SUM(REHANDLE),0) AS TotalMaterialMined 
FROM
(
    SELECT  shiftid,ShovelId, COUNT(dumps.FieldTons) AS NrDumps, shiftdumptime,
 (CASE WHEN Location LIKE '%INPIT%' THEN SUM(dumps.FieldTons) ELSE 0 END) AS Inpit, --
 (CASE WHEN Location LIKE '%X' AND dumps.Description NOT LIKE '%OXD' THEN SUM(dumps.FieldTons) ELSE 0 END) AS MWastePlus,
 (CASE WHEN Location NOT LIKE '%INPIT%' AND (dumps.FieldGrade NOT LIKE '%SX%' AND dumps.FieldGrade NOT LIKE '%LSP%')
     AND FieldLoadRec IS NOT NULL THEN SUM(dumps.FieldTons) ELSE 0 END)  AS ExPit, 
 (CASE WHEN Location LIKE '%X' AND dumps.Description LIKE '%OXD' THEN SUM(dumps.FieldTons) ELSE 0 END) AS Oxide,
 (CASE WHEN Location LIKE '%CRUSHER%' THEN SUM(dumps.FieldTons) ELSE 0 END) AS TDC,
 (CASE WHEN Location LIKE '%W' THEN SUM(dumps.FieldTons) ELSE 0 END) AS Waste,
 (CASE WHEN Location LIKE '%M' THEN SUM(dumps.FieldTons) ELSE 0 END) AS MWaste,
 (CASE WHEN Location LIKE '%T' AND Location NOT LIKE '%INPIT%' THEN SUM(dumps.FieldTons) ELSE 0 END) AS TPWaste, --Tailings Project Waste
 (CASE WHEN Location LIKE '%CRUSHER%' OR Location LIKE '%LSP%' OR Location LIKE '%SX STOCKPILE%' THEN SUM(dumps.FieldTons) ELSE 0 END) AS Ore,
 (CASE WHEN (dumps.FieldGrade) LIKE '%SX%' OR (dumps.FieldGrade) LIKE '%LSP%' THEN SUM(dumps.FieldTons) ELSE 0 END) AS Rehandle
    FROM
    (
        SELECT      si.shiftid,ld.LoadRec as FieldLoadrec, ld.EXCAV as ShovelId, ld.dumptons as FieldTons, ld.Loc AS Location, ld.GRADE AS FieldGrade, 
         enum.Description AS Description, ld.Calculated_ShiftIndex AS shiftindex, ld.TIMEDUMP_TS as shiftdumptime
        FROM        dbo.lh_dump ld
        LEFT JOIN   bag.enum enum on ld.load = enum.flags and enum.ABBREVIATION = 'load' 
		LEFT JOIN   dbo.SHIFT_INFO_V si ON ld.SHIFTINDEX = si.ShiftIndex AND si.siteflag = 'BAG'
        WHERE       ld.SITE_CODE = 'BAG'
    ) As dumps
    GROUP BY ShovelId, Description, Location, FieldLoadRec, FieldGrade,shiftid,shiftdumptime
) AS ShiftDumpPerShovel
WHERE shiftid IS NOT NULL
GROUP BY ShovelId,shiftid,shiftdumptime





