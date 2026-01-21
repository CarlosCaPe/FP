CREATE VIEW [Arch].[CONOPS_ARCH_DELTA_C_V] AS


CREATE VIEW [Arch].[CONOPS_ARCH_DELTA_C_V]
AS

SELECT
a.shiftflag,
a.ShiftStartDateTime,
a.ShiftEndDateTime,
b.site_code as siteflag,
b.shiftid,
b.deltac_ts,
b.delta_c,
c.DeltaCTarget
FROM [dbo].[SHIFT_INFO_V] a (NOLOCK)

LEFT JOIN (
select site_code,
concat(concat(right(replace(cast(shiftdate as varchar(10)),'-',''),6),'00'),shift_code) as shiftid,
deltac_ts,
avg(delta_c) as delta_c
from [dbo].[delta_c] (nolock)
--WHERE site_code = '<SITECODE>'
group by site_code,deltac_ts,shiftdate,shift_code) b
ON a.shiftid = b.shiftid AND a.siteflag = b.site_code

LEFT JOIN (
SELECT 
substring(replace(EffectiveDate,'-',''),3,4) as shiftdate,
TotalDeltaC as DeltaCTarget
FROM [Arch].[plan_values_prod_sum] WITH (NOLOCK)) c
on left(a.shiftid,4) = c.shiftdate AND a.siteflag = '<SITECODE>'

