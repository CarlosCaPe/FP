CREATE VIEW [bag].[CONOPS_BAG_DELTA_C_V] AS


--select * from [bag].[CONOPS_BAG_DELTA_C_V] where shiftflag = 'prev' order by deltac_ts
CREATE VIEW [BAG].[CONOPS_BAG_DELTA_C_V]
AS

SELECT
a.shiftflag,
a.ShiftStartDateTime,
a.ShiftEndDateTime,
a.siteflag,
a.shiftid,
b.deltac_ts,
b.delta_c
FROM [bag].[CONOPS_BAG_SHIFT_INFO_V] a (NOLOCK)

LEFT JOIN (
select 
site_code,
shiftindex,
--concat(concat(right(replace(cast(shiftdate as varchar(10)),'-',''),6),'00'),shift_code) as shiftid,
deltac_ts,
avg(delta_c) as delta_c
from [dbo].[delta_c] (nolock)
where site_code = 'BAG'
AND deltac_ts is not null
group by site_code,deltac_ts,shiftindex
) b
ON a.shiftindex = b.shiftindex AND a.siteflag = b.site_code
--order by b.deltac_ts asc




