CREATE VIEW [BAG].[CONOPS_BAG_SHIFT_OVERVIEW_V] AS

--select * from [bag].[CONOPS_BAG_SHIFT_OVERVIEW_V] where shiftid = '230221001'
CREATE VIEW [bag].[CONOPS_BAG_SHIFT_OVERVIEW_V]
AS

WITH ShiftDump AS (
SELECT 
	site_code,
	shift_id AS shiftid,
	shovel_name AS ShovelId,
	load_loc_name AS load_loc,
	dump_loc_name AS dump_loc,
	CAST(report_payload_short_tons AS INT) AS Tons,
	material_name AS material,
	grade AS FieldGrade
FROM BAG.FLEET_TRUCK_CYCLE_V
),


CTE AS(
SELECT
	site_code,
	shiftid,
	shovelid,
	Tons,
	--Material Category
	CASE WHEN load_loc LIKE '%INPIT%' OR load_loc = dump_loc THEN 'CM_Inpit'
		WHEN dump_loc LIKE '%Crusher%' OR dump_loc LIKE '%LSP%' OR dump_loc LIKE '%SX STOCKPILE%' THEN 'CM_Ore'
		WHEN dump_loc LIKE '%X' AND material LIKE '%OXD%' THEN 'CM_Oxide'
		WHEN dump_loc LIKE '%X' THEN 'CM_HGMWaste'
		WHEN dump_loc LIKE '%M' THEN 'CM_MWaste'
		WHEN dump_loc LIKE '%T' THEN 'CM_TPWaste'
		WHEN dump_loc LIKE '%W' THEN 'CM_Waste'
	ELSE 'CM_Unknown' END AS CM,

	--Source Destination Category
	CASE WHEN load_loc LIKE '%INPIT%' OR load_loc = dump_loc OR ((load_loc LIKE '%LSP%' OR load_loc LIKE '%SX STOCKPILE%')
			AND (dump_loc LIKE '%LSP%' OR dump_loc LIKE '%SX STOCKPILE%')) THEN 'CL_Inpit'
		WHEN dump_loc LIKE '%Crusher%' AND (load_loc NOT LIKE '%LSP%' AND load_loc NOT LIKE '%SX STOCKPILE%') THEN 'CL_Pit_Crusher'
		WHEN (load_loc LIKE '%LSP%' OR load_loc LIKE '%SX STOCKPILE%') AND dump_loc LIKE '%Crusher%' THEN 'CL_Stockpile_Crusher'
		WHEN dump_loc LIKE '%LSP%' OR dump_loc LIKE '%SX STOCKPILE%' THEN 'CL_Pit_Stockpile'
	ELSE 'CL_Pit_Waste' END AS CL
FROM ShiftDump
WHERE ShovelId IS NOT NULL
),

Summary AS(
SELECT 
	site_code,
	shiftid,
	shovelid,
	COUNT(*) AS NrOfDumps,
	CASE WHEN CL IN('CL_Inpit','CL_Pit_Crusher', 'CL_Stockpile_Crusher', 'CL_Pit_Stockpile', 'CL_Pit_Waste') THEN SUM(Tons) END AS TotalMaterialMoved,
	CASE WHEN CL IN('CL_Pit_Crusher', 'CL_Pit_Stockpile', 'CL_Pit_Waste') THEN SUM(Tons) END AS TotalMaterialMined,
	CASE WHEN CL IN('CL_Pit_Crusher', 'CL_Pit_Stockpile', 'CL_Pit_Waste') THEN SUM(Tons) END AS ExPitTons,
	CASE WHEN CL IN('CL_Stockpile_Crusher', 'CL_Pit_Crusher') THEN SUM(Tons) END AS TotalMaterialDeliveredToCrusher,
	CASE WHEN CL IN('CL_Stockpile_Crusher') THEN SUM(Tons) END AS RehandleOre,
	CASE WHEN CM = 'CM_Ore' AND CL NOT IN('CL_Inpit', 'CL_Stockpile_Crusher') THEN SUM(Tons) END AS MillOreMined,
	CASE WHEN CM IN ('CM_Oxide', 'CM_HGMWaste') THEN SUM(Tons) END AS ROMMined,
	0 AS CrushLeachMined,
	CASE WHEN CM IN ('CM_MWaste', 'CM_TPWaste', 'CM_Waste', 'CM_Unknown') THEN SUM(Tons) END AS WasteMined
FROM CTE
GROUP BY site_code, shiftid, shovelid, CL, CM
)

SELECT
	--site_code,
	shiftid,
	shovelid,
	SUM(NrOfDumps) AS NrOfDumps,
	SUM(TotalMaterialMoved) AS TotalMaterialMoved,
	SUM(TotalMaterialMined) AS TotalMaterialMined,
	SUM(ExPitTons) AS ExPitTons,
	SUM(TotalMaterialDeliveredToCrusher) AS TotalMaterialDeliveredToCrusher,
	SUM(RehandleOre) AS RehandleOre,
	SUM(MillOreMined) AS MillOreMined,
	SUM(ROMMined) AS ROMLeachMined,
	SUM(CrushLeachMined) AS CrushedLeachMined,
	SUM(WasteMined) AS WasteMined
FROM Summary
GROUP BY shiftid, shovelid





