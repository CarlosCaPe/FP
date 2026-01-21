CREATE VIEW [MOR].[CONOPS_MOR_OVERALL_DELTA_C_V] AS


--select * from [mor].[CONOPS_MOR_OVERALL_DELTA_C_V]
CREATE VIEW [mor].[CONOPS_MOR_OVERALL_DELTA_C_V] 
AS

SELECT
    a.shiftflag,
    a.siteflag,
    a.shiftid,
    AVG(b.delta_c) AS delta_c,
    ISNULL(ps.Delta_c_target, 0) AS DeltaCTarget
FROM 
    [mor].[CONOPS_MOR_SHIFT_INFO_V] a (NOLOCK)
LEFT JOIN (
    SELECT 
        site_code,
        shiftindex,
        AVG(delta_c) AS delta_c
    FROM 
        [dbo].[delta_c] (NOLOCK)
    WHERE 
        site_code = 'MOR'
    GROUP BY 
        site_code, shiftindex
) b ON a.shiftindex = b.shiftindex AND a.siteflag = b.site_code
LEFT JOIN (
    SELECT
        DateEffective,
        DeltaC AS Delta_c_target
    FROM 
        [mor].[plan_values_prod_sum] (NOLOCK)
) ps ON FORMAT(a.ShiftStartDateTime, 'yyyy-MM') = FORMAT(ps.DateEffective, 'yyyy-MM')
WHERE 
    a.siteflag = 'MOR'
GROUP BY 
    a.shiftflag, a.siteflag, a.shiftid, ps.Delta_c_target


