CREATE VIEW [BAG].[CONOPS_BAG_SHIFT_SNAPSHOT_V] AS

--SELECT * FROM [bag].[CONOPS_BAG_SHIFT_SNAPSHOT_V]
CREATE VIEW [bag].[CONOPS_BAG_SHIFT_SNAPSHOT_V]
AS


WITH ShiftDump AS (
SELECT 
	site_code,
	shift_id AS shiftid,
	DUMPINGSTARTTIME_LOCAL_TS AS shiftdumptime,
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
	shiftdumptime,
	shovelid,
	Tons,
	--Source Destination Category
	CASE WHEN load_loc LIKE '%INPIT%' OR load_loc = dump_loc OR ((load_loc LIKE '%LSP%' OR load_loc LIKE '%SX STOCKPILE%')
			AND (dump_loc LIKE '%LSP%' OR dump_loc LIKE '%SX STOCKPILE%')) THEN 'CL_Inpit'
		WHEN dump_loc LIKE '%Crusher%' AND (load_loc NOT LIKE '%LSP%' AND load_loc NOT LIKE '%SX STOCKPILE%') THEN 'CL_Pit_Crusher'
		WHEN (load_loc LIKE '%LSP%' OR load_loc LIKE '%SX STOCKPILE%') AND dump_loc LIKE '%Crusher%' THEN 'CL_Stockpile_Crusher'
		WHEN dump_loc LIKE '%LSP%' OR dump_loc LIKE '%SX STOCKPILE%' THEN 'CL_Pit_Stockpile'
	ELSE 'CL_Pit_Waste' END AS CL
FROM ShiftDump
WHERE ShovelId IS NOT NULL
)

SELECT 
	--site_code,
	shiftid,
	shiftdumptime,
	shovelid,
	COUNT(*) AS NrOfDumps,
	CASE WHEN CL IN('CL_Pit_Crusher', 'CL_Pit_Stockpile', 'CL_Pit_Waste') THEN Tons ELSE NULL END AS TotalMaterialMined
FROM CTE
GROUP BY shiftid, shiftdumptime, shovelid, CL, Tons


