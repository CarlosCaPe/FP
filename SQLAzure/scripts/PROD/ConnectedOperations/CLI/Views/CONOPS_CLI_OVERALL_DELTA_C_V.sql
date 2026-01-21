CREATE VIEW [CLI].[CONOPS_CLI_OVERALL_DELTA_C_V] AS



--select * from [cli].[CONOPS_CLI_OVERALL_DELTA_C_V]
CREATE VIEW [cli].[CONOPS_CLI_OVERALL_DELTA_C_V] 
AS

SELECT
a.shiftflag,
a.siteflag,
a.shiftid,
avg(b.delta_c) As delta_c,
8.6 DeltaCTarget
FROM [cli].[CONOPS_CLI_SHIFT_INFO_V] a (NOLOCK)
LEFT JOIN (
select site_code,
concat(concat(right(replace(cast(shiftdate as varchar(10)),'-',''),6),'00'),shift_code) as shiftid,
avg(delta_c) as delta_c
from [dbo].[delta_c] (nolock)
where site_code = 'CLI'
group by site_code,shiftdate,shift_code) b
ON a.shiftid = b.shiftid AND a.siteflag = 'CMX'


WHERE a.siteflag = 'CMX'

GROUP BY a.shiftflag,a.siteflag,a.shiftid


