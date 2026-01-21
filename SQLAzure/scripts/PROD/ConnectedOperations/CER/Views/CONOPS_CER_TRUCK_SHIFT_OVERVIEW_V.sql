CREATE VIEW [CER].[CONOPS_CER_TRUCK_SHIFT_OVERVIEW_V] AS



--SELECT * FROM [cer].[CONOPS_CER_TRUCK_SHIFT_OVERVIEW_V] WHERE shiftid = '230121001'
CREATE VIEW [CER].[CONOPS_CER_TRUCK_SHIFT_OVERVIEW_V]
AS

WITH CTE AS (
    SELECT    
        sd.ShiftId,
        s.FieldId AS [TruckId],
        enum.Idx AS [Load],
        (SELECT TOP 1 FieldId FROM cer.shift_loc WITH (NOLOCK) WHERE shift_loc_id = sd.FieldLoc) AS loc,
        sd.FieldLsizetons AS [LfTons],
        sd.FieldTimedump
    FROM cer.shift_dump_v sd WITH (NOLOCK)
    LEFT JOIN cer.shift_loc sl WITH (NOLOCK) ON sl.shift_loc_id = sd.FieldLoc
    LEFT JOIN cer.shift_eqmt s WITH (NOLOCK) ON s.shift_eqmt_id = sd.FieldTruck
    LEFT JOIN cer.enum enum WITH (NOLOCK) ON sd.FieldLoad = enum.enum_id
    WHERE enum.Idx NOT IN (26, 27, 28, 29, 30, 35)
),

Dumps AS (
    SELECT
        shiftid,
        TruckId,
        COUNT(LfTons) AS NrDumps,
        SUM(LfTons) AS Tons,
        CASE 
            WHEN [load] IN (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 15, 16, 17, 23, 31, 32, 34, 36, 37, 38, 39, 42, 43, 44, 45) THEN 'Mined'
            WHEN [load] IN (14, 18, 19, 20, 21, 22, 24, 33, 40, 41) THEN 'Rehandle'
            WHEN [load] = 25 THEN 'Inpit'
            ELSE 'Other'
        END AS Material,
        CASE 
            WHEN loc IN ('MILLCHAN', 'MILLCRUSH1', 'MILLCRUSH2', 'MILLSTK3-C2') THEN 'Mill'
            WHEN loc IN ('HIDROCHAN') THEN 'Crush Leach'
            WHEN loc LIKE 'P1X%' OR loc LIKE 'P4B%' THEN 'ROM'
            WHEN (LEFT(loc, 1) = 'S' OR LEFT(loc, 3) = 'DIN') AND RIGHT(loc, 2) = 'C1' THEN 'C1-Stocks'
            WHEN (LEFT(loc, 1) = 'S' OR LEFT(loc, 3) = 'DIN') AND RIGHT(loc, 2) = 'C2' THEN 'C2-Stocks'
            WHEN (LEFT(loc, 1) = 'S' OR LEFT(loc, 3) = 'DIN') AND RIGHT(loc, 2) = 'CL' THEN 'CL-Stocks'
            WHEN LEFT(loc, 5) = 'INPIT' THEN 'INPIT'
            WHEN LEFT(loc, 10) = 'SOBRECARGA' THEN 'Overload'
            WHEN loc NOT IN ('MILLCHAN', 'HIDRO-C1', 'MILLCRUSH1', 'MILLCRUSH2', 'HIDROCHAN', 'MILLSTK3-C2') 
                AND LEFT(loc, 1) <> 'S' 
                AND LEFT(loc, 3) <> 'DIN' 
                AND LEFT(loc, 3) <> 'P1X' 
                AND LEFT(loc, 3) <> 'P4B' 
                AND LEFT(loc, 5) <> 'INPIT' 
                AND LEFT(loc, 10) <> 'SOBRECARGA' THEN 'Waste'
        END AS Process
    FROM CTE
    GROUP BY
        shiftid,
        TruckId,
        [load],
        loc
)

SELECT
    shiftid,
    TruckId,
    SUM(NrDumps) AS NrOfDump,
    SUM(CASE WHEN Material = 'Mined' THEN tons ELSE 0 END) AS TotalMaterialMined,
    SUM(tons) AS TotalMaterialMoved,
    SUM(CASE WHEN Material = 'Mined' AND Process = 'Mill' THEN tons ELSE 0 END) AS MillMined,
    SUM(CASE WHEN Process = 'Mill' THEN tons ELSE 0 END) AS MillMoved,
    SUM(CASE WHEN Material = 'Mined' AND Process = 'ROM' THEN tons ELSE 0 END) AS ROMMined,
    SUM(CASE WHEN Process = 'ROM' THEN tons ELSE 0 END) AS ROMMoved,
    SUM(CASE WHEN Material = 'Mined' AND Process = 'Waste' THEN tons ELSE 0 END) AS WasteMined,
    SUM(CASE WHEN Process = 'Waste' THEN tons ELSE 0 END) AS WasteMoved,
    SUM(CASE WHEN Material = 'Mined' AND Process = 'Crush Leach' THEN tons ELSE 0 END) AS CrushLeachMined,
    SUM(CASE WHEN Process = 'Crush Leach' THEN tons ELSE 0 END) AS CrushLeachMoved,
    SUM(CASE WHEN Material = 'Mined' AND Process = 'Mill' THEN tons ELSE 0 END) AS TotalMaterialDeliveredToCrusher
FROM dumps
GROUP BY shiftid, TruckId


