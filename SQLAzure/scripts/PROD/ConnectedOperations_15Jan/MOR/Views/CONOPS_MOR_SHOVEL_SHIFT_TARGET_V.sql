CREATE VIEW [MOR].[CONOPS_MOR_SHOVEL_SHIFT_TARGET_V] AS




--select * from [mor].[CONOPS_MOR_SHOVEL_SHIFT_TARGET_V] where shiftflag = 'curr'
CREATE VIEW [mor].[CONOPS_MOR_SHOVEL_SHIFT_TARGET_V]
AS

WITH CTE AS (
    SELECT 
        Formatshiftid,
        shovel,
        CASE 
            WHEN destination NOT IN ('STC9999', 'IPC3M') AND destination NOT LIKE '%L4' AND destination NOT LIKE '%W' THEN 'ROMLeach'
            WHEN destination = 'STC9999' THEN 'CrushLeach'
            WHEN destination = 'IPC3M' THEN 'MillOre'
            WHEN destination IN ('MOL5965L', 'WCP3700L') THEN 'Waste'
            ELSE destination 
        END AS destination,
        SUM(ton) AS shovelshifttarget
    FROM 
        [mor].[xecute_plan_values] (NOLOCK)
    GROUP BY 
		shovel, destination, Formatshiftid
)

SELECT
    siteflag,
    shiftflag,
    shiftid,
    shovel AS shovelid,
    destination,
    shovelshifttarget,
    ShiftDuration / 3600.0 AS ShiftCompleteHour,
    ((ShiftDuration / 3600.0) / 12.0) * shovelshifttarget AS ShovelTarget
FROM 
    [mor].[CONOPS_MOR_SHIFT_INFO_V] a
LEFT JOIN 
    CTE b ON a.shiftid = b.Formatshiftid;




