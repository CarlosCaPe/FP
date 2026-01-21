CREATE VIEW [MOR].[CONOPS_MOR_SHIFT_TARGET_V] AS



--select * from [mor].[CONOPS_MOR_SHIFT_TARGET_V]
CREATE VIEW [mor].[CONOPS_MOR_SHIFT_TARGET_V]
AS


WITH CTE AS (
    SELECT 
        substring(replace(DateEffective, '-', ''), 3, 4) AS shiftdate,
        EquivalentFlatHaul AS EFHShifttarget
    FROM 
        [mor].[plan_values_prod_sum] (nolock)
),

TG AS (
    SELECT 
        Formatshiftid,
        SUM(CAST(ton AS integer)) AS ShiftTarget
    FROM 
        [mor].[xecute_plan_values] (NOLOCK)
    GROUP BY 
        Formatshiftid
)

SELECT
    siteflag,
    shiftflag,
    shiftid,
    ShiftTarget,
    ROUND(((ShiftDuration / 3600.0) / 12.0) * ShiftTarget, 0) AS TargetValue,
    EFHShifttarget,
    ROUND(((ShiftDuration / 3600.0) / 12.0) * EFHShifttarget, 0) AS EFHTarget
FROM 
    [mor].[CONOPS_MOR_SHIFT_INFO_V] a
LEFT JOIN 
    TG b ON a.shiftid = b.Formatshiftid
LEFT JOIN 
    CTE c ON LEFT(a.shiftid, 4) = c.shiftdate;


