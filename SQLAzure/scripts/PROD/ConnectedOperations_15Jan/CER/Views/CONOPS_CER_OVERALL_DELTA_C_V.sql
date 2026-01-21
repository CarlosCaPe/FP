CREATE VIEW [CER].[CONOPS_CER_OVERALL_DELTA_C_V] AS


--select * from [cer].[CONOPS_CER_OVERALL_DELTA_C_V]
CREATE VIEW [cer].[CONOPS_CER_OVERALL_DELTA_C_V]
AS

SELECT
a.shiftflag,
a.siteflag,
a.shiftid,
avg(b.delta_c) As delta_c,
ISNULL(ps.Delta_c_target,0) AS DeltaCTarget
FROM [cer].[CONOPS_CER_SHIFT_INFO_V] a (NOLOCK)
LEFT JOIN (
select site_code,
concat(concat(right(replace(cast(shiftdate as varchar(10)),'-',''),6),'00'),shift_code) as shiftid,
avg(delta_c) as delta_c
from [dbo].[delta_c] (nolock)
where site_code = 'CER'
group by site_code,shiftdate,shift_code) b
ON a.shiftid = b.shiftid AND a.siteflag = b.site_code
LEFT JOIN (
SELECT 
shiftid,
Delta_c_target
FROM [cer].[CONOPS_CER_DELTA_C_TARGET_V] (nolock)) ps
on a.shiftid = ps.shiftid


WHERE a.siteflag = 'CER'

GROUP BY a.shiftflag,a.siteflag,a.shiftid,ps.Delta_c_target

