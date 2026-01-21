CREATE VIEW [mor].[CONOPS_MOR_HOURLY_TOTALMATERIALMINED_V] AS



    
--select * from [mor].[CONOPS_MOR_HOURLY_TOTALMATERIALMINED_V] order by shiftseq      
CREATE VIEW [mor].[CONOPS_MOR_HOURLY_TOTALMATERIALMINED_V]      
AS

WITH ShiftDump AS (
	SELECT   
        sd.shiftid,
        s.FieldId AS [ShovelId],
        sd.FieldLsizetons AS [Tons],
        sl.FieldId AS [Location],
        slloc.FieldId AS [LoadLoc],
        enum.[Description],
		sd.dumptime_ts,
		sd.dumptime_hos
    FROM mor.shift_dump_v sd WITH (NOLOCK)
    LEFT JOIN mor.shift_load sload WITH (NOLOCK) ON sd.id = sload.FieldDumprec
    LEFT JOIN mor.shift_eqmt s WITH (NOLOCK) ON s.Id = sd.FieldExcav
    LEFT JOIN mor.shift_loc sl WITH (NOLOCK) ON sl.Id = sd.FieldLoc
    LEFT JOIN mor.shift_loc slloc WITH (NOLOCK) ON slloc.Id = sload.FieldLoc
    LEFT JOIN mor.enum enum WITH (NOLOCK) ON sd.FieldLoad = enum.Id
    WHERE (s.FieldId LIKE 'S%' OR s.FieldId IN ('L58', 'L59'))
),


CTE AS(
    SELECT   
        sd.shiftid,
        sd.ShovelId,
        sd.Tons,
		dumptime_hos,
		dumptime_ts,
        CASE 
            WHEN sd.[Location] LIKE '%MFL' AND sd.LoadLoc NOT LIKE '%-MFL' THEN sd.Tons
            ELSE 0
        END AS [TotalCrushedLeachMined],
        CASE 
            WHEN (sd.LoadLoc LIKE '%-MFL' OR sd.LoadLoc LIKE '%-MILL') THEN sd.Tons
            ELSE 0
        END AS [TotalTransferOre],
        CASE 
            WHEN (sd.[Location] LIKE '%L4' OR sd.[Location] LIKE '%W') AND sd.LoadLoc NOT LIKE '%-MFL' AND sd.LoadLoc NOT LIKE '%-MILL' THEN sd.Tons
            ELSE 0
        END AS [TotalWasteMined],
        CASE 
            WHEN sd.[Location] LIKE '%MIL%' AND sd.LoadLoc NOT LIKE '%-MILL' THEN sd.Tons
            ELSE 0
        END AS [TotalMillOreMined],
        CASE 
            WHEN sd.[Location] NOT LIKE '%MFL' AND sd.[Location] NOT LIKE '%MIL%' AND sd.[Location] NOT LIKE '%L4' AND sd.[Location] NOT LIKE '%W' AND sd.LoadLoc NOT LIKE '%-MFL' AND sd.LoadLoc NOT LIKE '%-MILL' THEN sd.Tons
            ELSE 0
        END AS [TotalROMLeachMined],
        CASE 
            WHEN sd.[Location] LIKE 'C%MFL' OR sd.[Location] LIKE 'C%MIL' THEN sd.Tons
            ELSE 0
        END AS [TotalDeliveredToCrushers]
    FROM ShiftDump sd
),

ShovelByRegion AS (
    SELECT pe.FieldId AS [ShovelId]
    FROM mor.pit_excav pe WITH (NOLOCK)
    INNER JOIN mor.pit_loc ppl WITH (NOLOCK) ON ppl.Id = pe.FieldLoc
    INNER JOIN mor.pit_loc pplr WITH (NOLOCK) ON pplr.Id = ppl.FieldRegion
    UNION
    SELECT DISTINCT sd.ShovelId
    FROM ShiftDump sd
),

Summary AS(
SELECT  
    sdps.shiftid,
	dumptime_hos,
	CAST(FORMAT(dumptime_ts, 'yyyy-MM-dd HH:mm:00') AS DATETIME) AS dumping_time,
    COUNT(*) AS [NrOfDumps],
    (ISNULL(SUM(sdps.TotalMillOreMined), 0) + ISNULL(SUM(sdps.TotalROMLeachMined), 0) + ISNULL(SUM(sdps.TotalCrushedLeachMined), 0) + ISNULL(SUM(sdps.TotalWasteMined), 0) + ISNULL(SUM(sdps.TotalTransferOre), 0)) AS [TotalMineralsMined],
    (ISNULL(SUM(sdps.TotalMillOreMined), 0) + ISNULL(SUM(sdps.TotalROMLeachMined), 0) + ISNULL(SUM(sdps.TotalCrushedLeachMined), 0) + ISNULL(SUM(sdps.TotalWasteMined), 0)) AS [TotalMaterialMined],
    ISNULL(SUM(sdps.TotalTransferOre), 0) AS [RehandleOre],
    ISNULL(SUM(sdps.TotalMillOreMined), 0) AS [MillOreMined],
    ISNULL(SUM(sdps.TotalROMLeachMined), 0) AS [ROMLeachMined],
    ISNULL(SUM(sdps.TotalCrushedLeachMined), 0) AS [CrushedLeachMined],
    ISNULL(SUM(sdps.TotalWasteMined), 0) AS [WasteMined],
    ISNULL(SUM(sdps.TotalDeliveredToCrushers), 0) AS [TotalMaterialDeliveredToCrusher]
FROM ShovelByRegion sbr
LEFT JOIN CTE sdps ON sdps.ShovelId = sbr.ShovelId
GROUP BY sdps.shiftid, dumptime_hos, dumptime_ts
),

GroupDumpTime AS(
SELECT
	--site_code,
	shiftid,
	dumptime_hos,
	SUM(NrOfDumps) AS NrOfDumps,
	SUM(TotalMineralsMined) AS TotalMaterialMoved,
	SUM(TotalMaterialMined) AS TotalMaterialMined,
	SUM(TotalMaterialDeliveredToCrusher) AS TotalMaterialDeliveredToCrusher,
	SUM(RehandleOre) AS Rehand