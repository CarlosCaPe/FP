CREATE VIEW [BAG].[CONOPS_BAG_OVERALL_DELTA_C_V] AS

--select * from [bag].[CONOPS_BAG_OVERALL_DELTA_C_V]
CREATE VIEW [bag].[CONOPS_BAG_OVERALL_DELTA_C_V] 
AS

SELECT a.shiftflag
	,a.siteflag
	,a.shiftid
	,avg(b.delta_c) AS delta_c
	,ISNULL(ps.Delta_c_target, 0) AS DeltaCTarget
FROM [bag].[CONOPS_BAG_SHIFT_INFO_V] a(NOLOCK)
LEFT JOIN (
	SELECT site_code
		,shiftindex
		,avg(delta_c) AS delta_c
	FROM [dbo].[delta_c](NOLOCK)
	WHERE site_code = 'BAG'
	GROUP BY site_code
		,shiftindex
	) b ON a.shiftindex = b.shiftindex
	AND a.siteflag = b.site_code
LEFT JOIN (
	SELECT substring(replace(EffectiveDate, '-', ''), 3, 4) AS shiftdate
		,TotalDeltaC AS Delta_c_target
	FROM [bag].[plan_values_prod_sum] WITH (NOLOCK)
	) ps ON LEFT(a.shiftid, 4) = ps.shiftdate
WHERE a.siteflag = 'BAG'
GROUP BY a.shiftflag
	,a.siteflag
	,a.shiftid
	,ps.Delta_c_target

