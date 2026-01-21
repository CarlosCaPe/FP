CREATE VIEW [MOR].[CONOPS_MOR_OVERALL_SHOVEL_DELTA_C_V] AS

--select * from [mor].[CONOPS_MOR_OVERALL_SHOVEL_DELTA_C_V]
CREATE VIEW [mor].[CONOPS_MOR_OVERALL_SHOVEL_DELTA_C_V]
AS

WITH CTE AS (
SELECT
	SiteFlag,
	ShiftId,
	Excav,
	SUM(FieldTons) AS Tons,
	COUNT(*) AS NrOfLoad
FROM mor.shift_load_detail_v
GROUP BY
	SiteFlag,
	ShiftId,
	Excav
), 

ShovelTons AS (
SELECT 
    shiftid, 
    excav, 
    SUM(NrofLoad) AS NrofLoad, 
    SUM(Tons) AS Tons
FROM CTE
GROUP BY shiftid, excav
),  

STAT AS (
SELECT
    shiftid,
    eqmt,
    eqmttype,
    reasonidx,
    reasons,
    [status] AS eqmtcurrstatus,
    ROW_NUMBER() OVER (PARTITION BY shiftid, eqmt ORDER BY startdatetime DESC) AS num
FROM [MOR].[asset_efficiency] (NOLOCK)
WHERE unittype = 'shovel'
)

SELECT
    a.shiftflag,
    a.siteflag,
    b.excav,
    d.eqmttype,
    SUM(Delta_c * Tons) / SUM(Tons) AS DeltaC,
    ShiftTarget,
    eqmtcurrstatus
FROM [mor].[CONOPS_MOR_SHIFT_INFO_V] a
LEFT JOIN [DBO].delta_c b WITH (NOLOCK) ON a.shiftindex = b.shiftindex AND b.site_code = 'MOR'
LEFT JOIN ShovelTons c ON a.shiftid = c.shiftid AND b.excav = c.excav
LEFT JOIN STAT d ON a.shiftid = d.shiftid AND b.EXCAV = d.eqmt AND d.num = 1
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
    d.eqmttype, 
    ShiftTarget, 
    eqmtcurrstatus

