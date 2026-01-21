CREATE VIEW [cli].[CONOPS_CLI_DELTA_C_V] AS





--select * from [cli].[CONOPS_CLI_DELTA_C_V]
CREATE VIEW [cli].[CONOPS_CLI_DELTA_C_V]  
AS

SELECT
a.shiftflag,
a.ShiftStartDateTime,
a.ShiftEndDateTime,
a.siteflag,
a.shiftid,
b.deltac_ts,
b.delta_c
FROM [cli].[CONOPS_CLI_SHIFT_INFO_V] a (NOLOCK)

LEFT JOIN (
select 
site_code,
shiftindex,
--concat(concat(right(replace(cast(shiftdate as varchar(10)),'-',''),6),'00'),shift_code) as shiftid,
deltac_ts,
avg(delta_c) as delta_c
from [dbo].[delta_c] (nolock)
where site_code = 'CLI'
group by site_code,deltac_ts,shiftindex) b
ON a.shiftindex = b.shiftindex AND a.siteflag = 'CMX'
--order by b.deltac_ts asc

WHERE a.siteflag = 'CMX'

