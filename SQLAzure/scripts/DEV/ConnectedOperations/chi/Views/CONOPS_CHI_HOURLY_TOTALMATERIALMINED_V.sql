CREATE VIEW [chi].[CONOPS_CHI_HOURLY_TOTALMATERIALMINED_V] AS




    
--select * from [CHI].[CONOPS_CHI_HOURLY_TOTALMATERIALMINED_V] order by shiftseq      
CREATE VIEW [CHI].[CONOPS_CHI_HOURLY_TOTALMATERIALMINED_V]      
AS

WITH ShiftDump AS (
    SELECT 
        enums.[DESCRIPTION] AS [Load],
        dumps.shiftid,
        s.FieldId AS [ShovelId],
        l.FieldId AS loc,
        dumps.FIELDLSIZEDB AS [LfTons],
        dumps.dumptime_ts,
        dumps.dumptime_hos
    FROM chi.shift_dump_v dumps WITH (NOLOCK)
    LEFT JOIN chi.shift_loc l WITH (NOLOCK) ON l.Id = dumps.FieldLoc
    LEFT JOIN chi.shift_eqmt s WITH (NOLOCK) ON s.Id = dumps.FieldExcav AND s.SHIFTID = dumps.origshiftid
    LEFT JOIN chi.enum enums WITH (NOLOCK) ON enums.Id = dumps.FieldLoad
    WHERE enums.Idx NOT IN (2)
    --AND s.ID IS NOT NULL
),

CTE AS (
    SELECT 
        [shiftid],
        [ShovelId],
        LfTons AS TotalMaterial,
        dumptime_hos,
        dumptime_ts,
        CASE
            WHEN [Load] NOT LIKE 'ORE REHANDLE' AND loc NOT LIKE 'ROADFILL%' AND loc NOT LIKE 'OVERLOAD%' THEN LfTons
            ELSE 0
        END AS [TotalExpit],
        CASE
            WHEN loc LIKE 'ROADFILL%' OR loc LIKE 'OVERLOAD%' THEN LfTons
            ELSE 0
        END AS [TotalInpit],
        CASE
            WHEN ([Load] LIKE 'WASTE' OR [Load] LIKE 'AC_WASTE' OR [Load] LIKE 'K_WASTE' OR [Load] LIKE 'LGL') 
                AND loc NOT LIKE 'ROADFILL%' 
                AND loc NOT LIKE 'OVERLOAD%' 
                AND loc NOT LIKE 'LB%' 
                AND loc NOT LIKE 'SD%' 
            THEN LfTons
            ELSE 0
        END AS [TotalWaste],
        CASE
            WHEN [Load] LIKE 'ROM' AND loc NOT LIKE 'ROADFILL%' AND loc NOT LIKE 'OVERLOAD%' 
                AND (loc LIKE 'SD%' OR loc LIKE 'LB%') 
            THEN LfTons
            ELSE 0
        END AS [TotalLeach],
        CASE
            WHEN [Load] LIKE 'ORE REHANDLE' THEN LfTons
            ELSE 0
        END AS [OreRehandletoCrusher],
        CASE
            WHEN [Load] LIKE 'ORE0%' AND loc NOT LIKE 'ROADFILL%' AND loc NOT LIKE 'OVERLOAD%' THEN LfTons
            ELSE 0
        END AS [TotalExpitOre],
        CASE
            WHEN loc LIKE 'CRUSHER' THEN LfTons
            ELSE 0
        END AS [TotalCrushedMillOre],
        CASE
            WHEN [Load] LIKE 'ORE0%' AND loc LIKE 'CRUSHER' THEN LfTons
            ELSE 0
        END AS [ExpitOreToCrusher]
    FROM ShiftDump sd
),

Summary AS (
    SELECT 
        Shiftid, 
        dumptime_hos,
        CAST(FORMAT(dumptime_ts, 'yyyy-MM-dd HH:mm:00') AS DATETIME) AS dumping_time,
        ISNULL(COUNT(*), 0) AS NrOfDumps,
        ISNULL(SUM(TotalMaterial), 0) AS TotalMaterialMoved,
        ISNULL(SUM([TotalExpit]), 0) AS TotalMaterialMined,
        ISNULL(SUM(TotalExpitOre), 0) AS MillOreMined,
        ISNULL(SUM(TotalLeach), 0) AS [ROMLeachMined],
        0 AS [CrushedLeachMined],
        ISNULL(SUM(TotalWaste), 0) AS WasteMined,
        ISNULL(SUM(TotalCrushedMillOre), 0) AS TotalMaterialDeliveredtoCrusher,
        ISNULL(SUM(TotalLeach), 0) AS LeachMined,
        ISNULL(SUM(TotalExpit), 0) AS TotalExpitMined,
        ISNULL(SUM(TotalInpit), 0) AS TotalInpitMined,
        ISNULL(SUM(OreRehandletoCrusher), 0) AS OreRehandletoCrusher,
        ISNULL(SUM(ExpitOreToCrusher), 0) AS ExpitOreToCrusher
    FROM CTE
    GROUP BY shiftid, dumptime_hos, dumptime_ts
),

GroupDumpTime AS (
    SELECT
        shiftid,
        dumptime_hos,
        SUM(NrOfDumps) AS NrOfDumps,
        SUM(TotalMaterialMoved) AS TotalMaterialMoved,
        SUM(TotalMaterialMined) AS TotalMaterialMined,
        SUM(TotalMaterialDeliveredToCrusher) AS TotalMaterialDeliveredToCrusher,
        SUM(OreRehandletoCrusher) AS RehandleOre,
        SUM(MillOreMined) AS MillOreMined,
        SUM(ROMLeachMined) AS ROMLeachMined,
        SUM(CrushedLeachMined) AS CrushedLeachMined,
        SUM(WasteMined) AS WasteMined
    FROM Summar