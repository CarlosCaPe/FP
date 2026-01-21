CREATE VIEW [CHI].[CONOPS_CHI_DELTA_C_V] AS




--select * from [chi].[CONOPS_CHI_DELTA_C_V]
CREATE VIEW [chi].[CONOPS_CHI_DELTA_C_V]  
AS

SELECT
a.shiftflag,
a.ShiftStartDateTime,
a.ShiftEndDateTime,
a.siteflag,
a.shiftid,
b.deltac_ts,
b.delta_c
FROM [chi].[CONOPS_CHI_SHIFT_INFO_V] a (NOLOCK)

LEFT JOIN (
select 
site_code,
shiftindex,
--concat(concat(right(replace(cast(shiftdate as varchar(10)),'-',''),6),'00'),shift_code) as shiftid,
deltac_ts,
avg(delta_c) as delta_c
from [dbo].[delta_c] (nolock)
where site_code = 'CHI'
group by site_code,deltac_ts,shiftindex) b
ON a.shiftindex = b.shiftindex AND a.siteflag = b.site_code
--order by b.deltac_ts asc

WHERE a.siteflag = 'CHI'

