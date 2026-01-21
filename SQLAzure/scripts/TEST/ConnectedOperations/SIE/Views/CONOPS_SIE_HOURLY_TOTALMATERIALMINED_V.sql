CREATE VIEW [SIE].[CONOPS_SIE_HOURLY_TOTALMATERIALMINED_V] AS


--select * from [SIE].[CONOPS_SIE_HOURLY_TOTALMATERIALMINED_V]
CREATE VIEW [SIE].[CONOPS_SIE_HOURLY_TOTALMATERIALMINED_V]
AS

WITH ShiftDump AS (
SELECT 
	dumps.siteflag as site_code,
	dumps.shiftid,
	s.FieldId AS [ShovelId],
	dl.FieldId AS dump_loc,
	ll.FieldId AS load_loc,
	enums.[DESCRIPTION] AS [Load],
	dumps.dumptime_ts,
	dumps.dumptime_hos,
	dumps.FIELDLSIZEDB AS [Tons]
FROM [SIE].shift_dump_v dumps WITH (NOLOCK)
LEFT JOIN [SIE].shift_loc dl WITH (NOLOCK) ON dl.Id = dumps.FieldLoc
LEFT JOIN [SIE].shift_eqmt s WITH (NOLOCK) ON s.Id = dumps.FieldExcav AND s.SHIFTID = dumps.shiftid
LEFT JOIN [SIE].shift_loc ll WITH (NOLOCK) ON ll.Id = dumps.FieldBlast
LEFT JOIN [SIE].enum enums WITH (NOLOCK) ON enums.Id=dumps.FieldLoad
WHERE s.FieldId IS NOT NULL
),


CTE AS(
SELECT
	site_code,
	shiftid,
	shovelid,
	dumptime_hos,
	dumptime_ts,
	Tons,
	--Material Category
	CASE WHEN Load = 'Ore' THEN 'CM_Ore'
		WHEN Load = 'Waste' THEN 'CM_Waste'
		WHEN Load LIKE '%Inpit%' THEN 'CM_Waste'
	ELSE 'CM_Unknown' END AS CM,

	--Source Destination Category
	CASE WHEN load_loc LIKE 'STO%' AND dump_loc IN ('CR13909O', 'A-SIDE', 'B-SIDE') THEN 'CL_Stockpile_Crusher'
		WHEN load_loc LIKE '%PB%' AND dump_loc IN ('CR13909O', 'A-SIDE', 'B-SIDE') THEN 'CL_Pit_Crusher'
		WHEN load_loc LIKE '%PB%'AND dump_loc LIKE 'STO%' THEN 'CL_Pit_Stockpile'
	ELSE 'CL_Pit_Waste' END AS CL
FROM ShiftDump
WHERE ShovelId IS NOT NULL
),

Summary AS(
SELECT 
	--site_code,
	shiftid,
	dumptime_hos,
	CAST(FORMAT(dumptime_ts, 'yyyy-MM-dd HH:mm:00') AS DATETIME) AS dumping_time,
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
GROUP BY site_code, shiftid, dumptime_hos, dumptime_ts, CL, CM
),

GroupDumpTime AS(
SELECT
	--site_code,
	shiftid,
	dumptime_hos,
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
GROUP BY shiftid, dumptime_hos
)

SELECT 
	s.siteflag,
	s.shiftflag,
	s.shiftid,
	s.shiftstartdatetime,
	s.shiftenddatetime,
	s.current_utc_offset,
	DATEADD(HOUR, f.dumptime_hos, s.shiftstartdatetime) AS TimeInHour,
	f.dumptime_hos AS shiftseq,
	f.TotalMaterialMined AS TotalMaterialMined,
	f.TotalMaterialMoved AS TotalMaterialMoved,
	f.MillOreMined AS Mill,
	f.ROMLeachMined AS ROM,
	f.WasteMined AS Waste,
	f.CrushedLeachMined AS CrushLeach,
	t.shifttarget,
	t.target
FROM SIE.CONOPS_SIE_SHIFT_INFO_V s
LEFT JOIN GroupDumpTime f
	ON s.shiftid = f.shiftid
LEFT JOI