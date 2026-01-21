CREATE VIEW [saf].[CONOPS_SAF_DELTA_C_WORST_TRUCK_V] AS


--select * from [saf].[CONOPS_SAF_DELTA_C_WORST_TRUCK_V]
CREATE VIEW [saf].[CONOPS_SAF_DELTA_C_WORST_TRUCK_V] 
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
ISNULL(ps.Delta_c_target,0) AS DeltaCTarget
FROM [saf].[CONOPS_SAF_SHIFT_INFO_V] a (NOLOCK)

LEFT JOIN (
select 
site_code,
shiftindex,
--concat(concat(right(replace(cast(shiftdate as varchar(10)),'-',''),6),'00'),shift_code) as shiftid,
truck,
deltac_ts,
avg(delta_c) as delta_c
from [dbo].[delta_c] (nolock)
where site_code = 'SAF'
group by site_code,truck,deltac_ts,shiftindex) b
ON a.shiftindex = b.shiftindex AND a.siteflag = b.site_code 

LEFT JOIN [saf].[CONOPS_SAF_DELTA_C_TARGET_V] ps WITH (NOLOCK)
ON a.shiftid = ps.shiftid AND a.siteflag = ps.siteflag


WHERE a.siteflag = 'SAF'

