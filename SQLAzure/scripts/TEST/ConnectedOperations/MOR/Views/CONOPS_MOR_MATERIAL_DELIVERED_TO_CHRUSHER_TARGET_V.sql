CREATE VIEW [MOR].[CONOPS_MOR_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V] AS


--select * from [mor].[CONOPS_MOR_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V] WITH (NOLOCK)
CREATE VIEW [mor].[CONOPS_MOR_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V] 
AS

WITH stc AS (
    SELECT 
        FormatShiftid AS shiftid,
        SUM(CAST(REPLACE(Ton, ',', '') AS float)) AS total
    FROM 
        [mor].[xecute_plan_values] (nolock)
    WHERE 
        Destination = 'STC9999'
    GROUP BY 
        FormatShiftid
),

ip AS (
    SELECT 
        FormatShiftid AS shiftid,
        SUM(CAST(REPLACE(Ton, ',', '') AS float)) AS total
    FROM 
        [mor].[xecute_plan_values] (nolock)
    WHERE 
        Destination = 'IPC3M'
    GROUP BY
        FormatShiftid
)

SELECT 
    [ShiftID],
    [Location],
    [Target]
FROM (
    SELECT 
        stc.[ShiftID],
        'Crusher 2' AS [Location], 
        stc.total + ((0.1 * (stc.total + ip.total)) * (stc.total / (stc.total + ip.total))) AS [Target]
    FROM 
        stc
    LEFT JOIN 
        ip ON stc.[ShiftID] = ip.[ShiftID]
) AS [C2]

UNION ALL

SELECT 
    [ShiftID],
    [Location],
    [Target]
FROM (
    SELECT 
        ip.[ShiftID],
        'Crusher 3' AS [Location], 
        ip.total + ((0.1 * (stc.total + ip.total)) * (ip.total / (stc.total + ip.total))) AS [Target]
    FROM 
        ip
    LEFT JOIN 
        stc ON stc.[ShiftID] = ip.[ShiftID]
) AS [C3];


