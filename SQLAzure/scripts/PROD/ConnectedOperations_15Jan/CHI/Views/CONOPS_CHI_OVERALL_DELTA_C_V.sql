CREATE VIEW [CHI].[CONOPS_CHI_OVERALL_DELTA_C_V] AS




--select * from [chi].[CONOPS_CHI_OVERALL_DELTA_C_V]
CREATE VIEW [chi].[CONOPS_CHI_OVERALL_DELTA_C_V] 
AS

SELECT a.shiftflag,
       a.siteflag,
       a.shiftid,
       avg(b.delta_c) AS delta_c,
       ISNULL(ps.Delta_c_target,0) AS DeltaCTarget
FROM [chi].[CONOPS_CHI_SHIFT_INFO_V] a (NOLOCK)
LEFT JOIN (
	 SELECT site_code,
            concat(concat(right(replace(cast(shiftdate AS varchar(10)), '-', ''), 6), '00'), shift_code) AS shiftid,
            avg(delta_c) AS delta_c
     FROM [dbo].[delta_c] (nolock)
     WHERE site_code = 'CHI'
     GROUP BY site_code,
              shiftdate,
              shift_code
) b ON a.shiftid = b.shiftid
AND a.siteflag = b.site_code
LEFT JOIN (
	 SELECT shiftid,
            Delta_c_target
     FROM [chi].[CONOPS_CHI_DELTA_C_TARGET_V] (nolock)
) ps ON LEFT(a.shiftid, 4) >= ps.shiftid
WHERE a.siteflag = 'CHI'
GROUP BY a.shiftflag,
         a.siteflag,
         a.shiftid,
         ps.Delta_c_target

