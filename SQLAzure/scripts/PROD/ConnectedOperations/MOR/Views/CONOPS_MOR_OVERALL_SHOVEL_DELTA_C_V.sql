CREATE VIEW [MOR].[CONOPS_MOR_OVERALL_SHOVEL_DELTA_C_V] AS



--select * from [mor].[CONOPS_MOR_OVERALL_SHOVEL_DELTA_C_V]
CREATE VIEW [mor].[CONOPS_MOR_OVERALL_SHOVEL_DELTA_C_V]
AS

WITH CTE AS (
    SELECT 
        shiftindex, 
        excav, 
        COUNT(excav) AS NrofLoad, 
        SUM(loadtons) AS Tons
    FROM dbo.lh_load WITH (NOLOCK)
    WHERE site_code = 'MOR'
    GROUP BY shiftindex, excav
), 

ShovelTons AS (
    SELECT 
        shiftindex, 
        excav, 
        SUM(NrofLoad) AS NrofLoad, 
        SUM(Tons) AS Tons
    FROM CTE
    GROUP BY shiftindex, excav
),  

STAT AS (
    SELECT 
        shiftid, 
        eqmt, 
        reasonidx, 
        reasons, 
        [status] AS eqmtcurrstatus,  
        ROW_NUMBER() OVER (PARTITION BY shiftid, eqmt ORDER BY startdatetime DESC) AS num
    FROM [MOR].[asset_efficiency] (NOLOCK)
    WHERE unittype = 'shovel'
),  

ET AS (
    SELECT 
        shiftindex, 
        eqmtid, 
        eqmttype
    FROM [dbo].[LH_EQUIP_LIST] WITH (NOLOCK)
    WHERE SITE_CODE = 'MOR' AND unit = 'Shovel'
)  

SELECT 
    a.shiftflag, 
    a.siteflag, 
    b.excav, 
    et.eqmttype, 
    SUM(Delta_c * Tons) / SUM(Tons) AS DeltaC, 
    ShiftTarget, 
    eqmtcurrstatus
FROM [mor].[CONOPS_MOR_SHIFT_INFO_V] a
LEFT JOIN [DBO].delta_c b WITH (NOLOCK) ON a.shiftindex = b.shiftindex AND b.site_code = 'MOR'
LEFT JOIN ShovelTons c ON a.shiftindex = c.shiftindex AND b.excav = c.excav
LEFT JOIN STAT d ON a.shiftid = d.shiftid AND b.EXCAV = d.eqmt AND d.num = 1
LEFT JOIN ET et ON a.SHIFTINDEX = et.SHIFTINDEX AND b.EXCAV = et.EQMTID
LEFT JOIN (
    SELECT 
        SUBSTRING(REPLACE(DateEffective, '-', ''), 3, 4) AS targetperiod, 
        DeltaC AS Shifttarget
    FROM [mor].[plan_values_prod_sum] WITH (NOLOCK)
) e ON LEFT(a.shiftid, 4) = e.targetperiod

GROUP BY 
    a.shiftflag, 
    a.siteflag, 
    b.excav, 
    et.eqmttype, 
    ShiftTarget, 
    eqmtcurrstatus


