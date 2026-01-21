CREATE VIEW [MOR].[CONOPS_MOR_DELTA_C_WORST_TRUCK_V] AS



--select * from [mor].[CONOPS_MOR_DELTA_C_WORST_TRUCK_V]
CREATE VIEW [mor].[CONOPS_MOR_DELTA_C_WORST_TRUCK_V] 
AS


SELECT
a.shiftflag,
a.ShiftStartDateTime,
a.ShiftEndDateTime,
a.siteflag,
a.shiftid,
b.truck,
b.deltac_ts,
b.delta_c,
ISNULL(c.DeltaCTarget,0) AS DeltaCTarget
FROM [mor].[CONOPS_MOR_SHIFT_INFO_V] a (NOLOCK)

LEFT JOIN (
select 
site_code,
shiftindex,
--concat(concat(right(replace(cast(shiftdate as varchar(10)),'-',''),6),'00'),shift_code) as shiftid,
truck,
deltac_ts,
avg(delta_c) as delta_c
from [dbo].[delta_c] (nolock)
where site_code = 'MOR'
group by site_code,truck,deltac_ts,shiftindex) b
ON a.shiftindex = b.shiftindex AND a.siteflag = b.site_code 

CROSS JOIN (
SELECT TOP 1
substring(replace(DateEffective,'-',''),3,4) as shiftdate,
DeltaC as DeltaCTarget
FROM [mor].[plan_values_prod_sum] WITH (NOLOCK)
ORDER BY DateEffective DESC) c


WHERE a.siteflag = 'MOR'



