CREATE VIEW [bag].[CONOPS_BAG_OVERALL_DELTA_C_V] AS





--select * from [bag].[CONOPS_BAG_OVERALL_DELTA_C_V]
CREATE VIEW [bag].[CONOPS_BAG_OVERALL_DELTA_C_V] 
AS

SELECT
a.shiftflag,
a.siteflag,
a.shiftid,
avg(b.delta_c) As delta_c,
ISNULL(ps.Delta_c_target,0) AS DeltaCTarget
FROM [bag].[CONOPS_BAG_SHIFT_INFO_V] a (NOLOCK)
LEFT JOIN (
select site_code,
concat(concat(right(replace(cast(shiftdate as varchar(10)),'-',''),6),'00'),shift_code) as shiftid,
avg(delta_c) as delta_c
from [dbo].[delta_c] (nolock)
where site_code = 'BAG'
group by site_code,shiftdate,shift_code) b
ON a.shiftid = b.shiftid AND a.siteflag = b.site_code
CROSS JOIN (
SELECT TOP 1
substring(replace(EffectiveDate,'-',''),3,4) as shiftdate,
TotalDeltaC as Delta_c_target
FROM [bag].[plan_values_prod_sum] (nolock)
ORDER BY EffectiveDate DESC) ps


WHERE a.siteflag = 'BAG'

GROUP BY a.shiftflag,a.siteflag,a.shiftid,ps.Delta_c_target

