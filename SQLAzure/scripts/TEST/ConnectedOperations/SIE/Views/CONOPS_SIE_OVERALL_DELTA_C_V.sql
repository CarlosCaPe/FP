CREATE VIEW [SIE].[CONOPS_SIE_OVERALL_DELTA_C_V] AS


--select * from [sie].[CONOPS_SIE_OVERALL_DELTA_C_V]
CREATE VIEW [sie].[CONOPS_SIE_OVERALL_DELTA_C_V] 
AS

SELECT
a.shiftflag,
a.siteflag,
a.shiftid,
avg(b.delta_c) As delta_c,
ISNULL(c.DeltaCTarget,0) As DeltaCTarget
FROM [sie].[CONOPS_SIE_SHIFT_INFO_V] a (NOLOCK)
LEFT JOIN (
select site_code,
concat(concat(right(replace(cast(shiftdate as varchar(10)),'-',''),6),'00'),shift_code) as shiftid,
avg(delta_c) as delta_c
from [dbo].[delta_c] (nolock)
where site_code = 'SIE'
group by site_code,shiftdate,shift_code) b
ON a.shiftid = b.shiftid AND a.siteflag = 'SIE'

CROSS JOIN (
SELECT TOP 1
substring(replace(cast(getdate() as date),'-',''),3,4) as shiftdate,
DeltaC as DeltaCTarget
FROM [sie].[plan_values_prod_sum] WITH (NOLOCK)
ORDER BY DateEffective DESC) c


WHERE a.siteflag = 'SIE'

GROUP BY a.shiftflag,a.siteflag,a.shiftid,c.DeltaCTarget

