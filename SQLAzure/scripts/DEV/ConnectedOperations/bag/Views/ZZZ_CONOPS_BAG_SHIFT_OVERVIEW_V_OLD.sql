CREATE VIEW [bag].[ZZZ_CONOPS_BAG_SHIFT_OVERVIEW_V_OLD] AS





--SELECT * FROM [bag].[CONOPS_BAG_SHIFT_OVERVIEW_V] WHERE SHIFTID = '230102001'

CREATE VIEW [bag].[CONOPS_BAG_SHIFT_OVERVIEW_V_OLD]
AS


SELECT  
sdps.shiftid,
sdps.ShovelId, 
NULLIF(CAST(SUM(sdps.NrDumps) AS INTEGER) , 0) AS NrOfDumps,
NULLIF(SUM(sdps.INPIT) + SUM(sdps.EXPIT) + SUM(sdps.REHANDLE),0) AS TotalMaterialMined,
NULLIF((SUM(sdps.MWastePlus) + SUM(sdps.Waste) + SUM(sdps.MWaste) + SUM(sdps.TPWaste) + SUM(sdps.Oxide)), 0) AS WasteMined,
NULLIF(SUM(sdps.Inpit),0) AS CrushedLeachMined, 
NULLIF(SUM(sdps.Ore),0) AS MillOreMined,
NULLIF(SUM(sdps.Oxide),0) AS ROMLeachMined, 
NULLIF(SUM(sdps.EXPIT),0) AS ExPitTons,
NULLIF(SUM(sdps.TDC),0) AS TotalMaterialDeliveredToCrusher, 
NULLIF(SUM(sdps.Rehandle),0) AS RehandledOre  
FROM
(
    SELECT  
	shiftid,
	ShovelId, 
	COUNT(dumps.FieldTons) AS NrDumps,
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
        SELECT    
		sd.shiftid,
		sd.FieldLoadrec, 
		s.FieldId as ShovelId, 
		sd.FieldLsizetons AS FieldTons, 
		sl.FieldId AS [Location], 
		sd.FieldGrade, 
        enum.[Description] AS [Description]
        FROM bag.shift_dump_v sd
        LEFT JOIN bag.shift_loc sl ON sl.Id = sd.FieldLoc
		LEFT JOIN bag.shift_eqmt s ON s.Id = sd.FieldExcav
		LEFT JOIN bag.enum enum ON sd.FieldLoad = enum.Id
    ) As dumps
    GROUP BY ShovelId, shiftid,description, Location, FieldLoadRec, FieldGrade
) AS sdps
GROUP BY shiftid,ShovelId


