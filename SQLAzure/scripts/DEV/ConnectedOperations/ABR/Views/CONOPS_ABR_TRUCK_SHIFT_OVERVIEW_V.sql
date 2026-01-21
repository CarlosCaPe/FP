CREATE VIEW [ABR].[CONOPS_ABR_TRUCK_SHIFT_OVERVIEW_V] AS







-- SELECT * FROM [abr].[CONOPS_ABR_TRUCK_SHIFT_OVERVIEW_V] where shiftid = '230807002' group by shiftid
CREATE VIEW [ABR].[CONOPS_ABR_TRUCK_SHIFT_OVERVIEW_V]
AS

WITH ShiftDump AS (
SELECT 
	dumps.siteflag as site_code,
	dumps.shiftid,
	t.FieldId AS [TruckId],
	dl.FieldId AS dump_loc,
	ll.FieldId AS load_loc,
	enums.[DESCRIPTION] AS [Load],
	dumps.FIELDLSIZEDB AS [Tons]
FROM [abr].shift_dump_v dumps WITH (NOLOCK)
LEFT JOIN [abr].shift_loc dl WITH (NOLOCK) ON dl.Id = dumps.FieldLoc
LEFT JOIN [abr].shift_eqmt t WITH (NOLOCK) ON t.Id = dumps.FieldTruck AND t.SHIFTID = dumps.shiftid
LEFT JOIN [abr].shift_loc ll WITH (NOLOCK) ON ll.Id = dumps.FieldBlast
LEFT JOIN [abr].enum enums WITH (NOLOCK) ON enums.Id=dumps.FieldLoad
WHERE t.FieldId IS NOT NULL
),


CTE AS(
SELECT
	site_code,
	shiftid,
	TruckId,
	Tons,
	--Material Category
	CASE WHEN load_loc LIKE 'I%' OR load_loc = dump_loc THEN 'CM_Inpit'
		WHEN dump_loc LIKE '%C.1%' OR dump_loc LIKE 'I%' THEN 'CM_Ore'
		WHEN dump_loc LIKE 'LAST%' THEN 'CM_Waste'
		WHEN dump_loc LIKE 'R2%' THEN 'CM_ROM'
	ELSE 'CM_Unknown' END AS CM,

	--Source Destination Category
	CASE WHEN dump_loc LIKE 'I%' THEN 'CL_Inpit'
		WHEN load_loc like 'F%' AND dump_loc LIKE '%C.1%' THEN 'CL_Pit_Crusher'
		WHEN load_loc LIKE 'S%' AND dump_loc LIKE '%C.1%' THEN 'CL_Stockpile_Crusher'
		WHEN load_loc like 'F%' AND dump_loc LIKE 'S%' THEN 'CL_Pit_Stockpile'
	ELSE 'CL_Pit_Waste' END AS CL
FROM ShiftDump
WHERE TruckId IS NOT NULL
),

Summary AS(
SELECT 
	--site_code,
	shiftid,
	TruckId,
	COUNT(*) AS NrOfDumps,
	CASE WHEN CL IN('CL_Inpit','CL_Pit_Crusher', 'CL_Stockpile_Crusher', 'CL_Pit_Stockpile', 'CL_Pit_Waste') THEN SUM(Tons) END AS TotalMaterialMoved,
	CASE WHEN CL IN('CL_Pit_Crusher', 'CL_Pit_Stockpile', 'CL_Pit_Waste') THEN SUM(Tons) END AS TotalMaterialMined,
	CASE WHEN CL IN('CL_Pit_Crusher', 'CL_Pit_Stockpile', 'CL_Pit_Waste') THEN SUM(Tons) END AS ExPitTons,
	CASE WHEN CL IN('CL_Stockpile_Crusher', 'CL_Pit_Crusher') THEN SUM(Tons) END AS TotalMaterialDeliveredToCrusher,
	CASE WHEN CL IN('CL_Pit_Crusher') THEN SUM(Tons) END AS TotalExpitOreToCrusher,
	CASE WHEN CL IN('CL_Stockpile_Crusher') THEN SUM(Tons) END AS RehandleOre,
	CASE WHEN CM = 'CM_Ore' AND CL IN('CL_Pit_Crusher', 'CL_Pit_Stockpile', 'CL_Pit_Waste') THEN SUM(Tons) END AS MillOreMined,
	CASE WHEN CM IN ('CM_ROM') AND CL IN('CL_Pit_Crusher', 'CL_Pit_Stockpile', 'CL_Pit_Waste') THEN SUM(Tons) END AS ROMMined,
	0 AS CrushLeachMined,
	CASE WHEN CM IN ('CM_Inpit','CM_Waste', 'CM_Unknown') AND CL IN('CL_Pit_Crusher', 'CL_Pit_Stockpile', 'CL_Pit_Waste') THEN SUM(Tons) END AS WasteMined,
	CASE WHEN CM IN ('CM_Inpit') AND CL IN('CL_Pit_Crusher', 'CL_Pit_Stockpile', 'CL_Pit_Waste') THEN SUM(Tons) END AS InPitTons
FROM CTE
GROUP BY site_code, shiftid, TruckId, CL, CM
)

SELECT
	--site_code,
	shiftid,
	TruckId,
	SUM(NrOfDumps) AS NrOfDumps,
	SUM(TotalMaterialMoved) AS TotalMaterialMoved,
	SUM(TotalMaterialMined) AS TotalMaterialMined,
	SUM(ExPitTons) AS TotalExPitMined,
	SUM(InPitTons) AS TotalInPitMined,
	SUM(TotalMaterialDeliveredToCrusher) AS TotalMaterialDeliveredToCrusher,
	SUM(TotalExpitOreToCrusher) AS ExpitOreToCrusher,
	SUM(RehandleOre) AS OreRehandleToCrusher,
	SUM(MillOreMined) AS MillOreMined,
	SUM(ROMMined) AS ROMLeachMined,
	SUM(CrushLeachMined) AS CrushedLeachMined,
	SUM(WasteMined) AS WasteMined
FROM Summary
GROUP BY shiftid, TruckId






