CREATE VIEW [Arch].[CONOPS_ARCH_OVERALL_DELTA_C_V] AS



CREATE VIEW [Arch].[CONOPS_ARCH_OVERALL_DELTA_C_V]
AS

SELECT
a.shiftflag,
a.siteflag,
a.shiftid,
avg(b.delta_c) As delta_c,
ISNULL(ps.Delta_c_target,0) AS DeltaCTarget
FROM [dbo].[SHIFT_INFO_V] a (NOLOCK)
LEFT JOIN (
select site_code,
concat(concat(right(replace(cast(shiftdate as varchar(10)),'-',''),6),'00'),shift_code) as shiftid,
avg(delta_c) as delta_c
from [dbo].[delta_c] (nolock)
--WHERE site_code = '<SITECODE>'
group by site_code,shiftdate,shift_code) b
ON a.shiftid = b.shiftid AND a.siteflag = b.site_code
LEFT JOIN (
SELECT 
substring(replace(EffectiveDate,'-',''),3,4) as shiftdate,
TotalDeltaC as Delta_c_target
FROM [Arch].[plan_values_prod_sum] (nolock)) ps
on left(a.shiftid,4) = ps.shiftdate

WHERE a.siteflag = '<SITECODE>'

GROUP BY a.shiftflag,a.siteflag,a.shiftid,ps.Delta_c_target

