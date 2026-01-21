CREATE VIEW [CLI].[CONOPS_CLI_DELTA_C_WORST_SHOVEL_V] AS


--select * from [cli].[CONOPS_CLI_DELTA_C_WORST_SHOVEL_V]
CREATE VIEW [cli].[CONOPS_CLI_DELTA_C_WORST_SHOVEL_V]  
AS


SELECT
a.shiftflag,
a.ShiftStartDateTime,
a.ShiftEndDateTime,
a.siteflag,
a.shiftid,
b.excav,
b.deltac_ts,
b.delta_c,
8.6 DeltaCTarget
FROM [cli].[CONOPS_CLI_SHIFT_INFO_V] a (NOLOCK)

LEFT JOIN (
select 
site_code,
shiftindex,
--concat(concat(right(replace(cast(shiftdate as varchar(10)),'-',''),6),'00'),shift_code) as shiftid,
excav,
deltac_ts,
avg(delta_c) as delta_c
from [dbo].[delta_c] (nolock)
where site_code = 'CLI'
group by site_code,excav,deltac_ts,shiftindex) b
ON a.shiftindex = b.shiftindex AND a.siteflag = 'CMX'

WHERE a.siteflag = 'CMX'


