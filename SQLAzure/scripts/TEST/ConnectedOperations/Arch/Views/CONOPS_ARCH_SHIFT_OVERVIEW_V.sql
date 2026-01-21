CREATE VIEW [Arch].[CONOPS_ARCH_SHIFT_OVERVIEW_V] AS
--USE [ConnectedOperations]
--GO

--/****** Object:  View [Arch].[CONOPS_ARCH_SHIFT_OVERVIEW_V]    Script Date: 2/27/2023 3:22:14 PM ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO




CREATE   VIEW [Arch].[CONOPS_ARCH_SHIFT_OVERVIEW_V]
AS


WITH ShiftDump AS (
SELECT
sd.shiftid,
s.FieldId AS [ShovelId],
sd.FIELDLSIZETONS as FieldTons,
sd.FIELDLOADREC,
ssloc.FieldId AS [Location],
sg.FieldId AS FieldGrade,
enum.[description] AS [description]
FROM ARCH.shift_dump sd WITH (NOLOCK)
LEFT JOIN ARCH.shift_eqmt s WITH (NOLOCK)
ON s.Id = sd.FieldExcav AND s.SHIFTID = sd.shiftid
LEFT JOIN ARCH.SHIFT_GRADE sg WITH (NOLOCK)
ON sd.FIELDGRADE = sg.Id AND sd.SHIFTID = sg.ShiftId
LEFT JOIN ARCH.shift_loc ssloc WITH (NOLOCK)
ON ssloc.Id = sd.FieldLoc AND ssloc.SHIFTID = sd.shiftid
LEFT JOIN ARCH.enum enum 
 ON sd.FieldLoad = enum.id and enum.ABBREVIATION = 'load' 
),

CTE AS (
SELECT  shiftid,ShovelId, COUNT(dumps.FieldTons) AS NrDumps,
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
FROm ShiftDump dumps 
GROUP BY ShovelId, Description, Location, FieldLoadRec, FieldGrade,shiftid)

SELECT  
shiftid,
ShovelId, 
NULLIF(CAST(SUM(NrDumps) AS INTEGER) , 0) AS NrOfDumps,
NULLIF(SUM(INPIT) + SUM(EXPIT) + SUM(REHANDLE),0) AS TotalMaterialMined,
NULLIF((SUM(MWastePlus) + SUM(Waste) + SUM(MWaste) + SUM(TPWaste) + SUM(Oxide)), 0) AS WasteMined,
NULLIF(SUM(Inpit),0) AS CrushedLeachMined, NULLIF(SUM(Ore),0) AS MillOreMined,
NULLIF(SUM(Oxide),0) AS ROMLeachMined, NULLIF(SUM(EXPIT),0) AS ExPitTons,
NULLIF(SUM(TDC),0) AS TotalMaterialDeliveredToCrusher, NULLIF(SUM(Rehandle),0) AS RehandledOre 
FROM CTE 
GROUP BY ShovelId,shiftid

--GO


