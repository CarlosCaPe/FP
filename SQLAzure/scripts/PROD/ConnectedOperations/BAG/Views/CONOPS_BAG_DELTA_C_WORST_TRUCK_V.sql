CREATE VIEW [BAG].[CONOPS_BAG_DELTA_C_WORST_TRUCK_V] AS

--select * from [bag].[CONOPS_BAG_DELTA_C_WORST_TRUCK_V]
CREATE VIEW [BAG].[CONOPS_BAG_DELTA_C_WORST_TRUCK_V]
AS

SELECT a.shiftflag
	,a.ShiftStartDateTime
	,a.ShiftEndDateTime
	,a.siteflag
	,a.shiftid
	,b.truck
	,b.deltac_ts
	,b.delta_c
	,ISNULL(c.DeltaCTarget, 0) AS DeltaCTarget
FROM [bag].[CONOPS_BAG_SHIFT_INFO_V] a(NOLOCK)
LEFT JOIN (
	SELECT site_code
		,shiftindex
		--concat(concat(right(replace(cast(shiftdate as varchar(10)),'-',''),6),'00'),shift_code) as shiftid,
		,truck
		,deltac_ts
		,avg(delta_c) AS delta_c
	FROM [dbo].[delta_c](NOLOCK)
	WHERE site_code = 'BAG'
		AND deltac_ts IS NOT NULL
	GROUP BY site_code
		,truck
		,deltac_ts
		,shiftindex
	) b ON a.shiftindex = b.shiftindex
	AND a.siteflag = b.site_code
LEFT JOIN (
	SELECT substring(replace(EffectiveDate, '-', ''), 3, 4) AS shiftdate
		,TotalDeltaC AS DeltaCTarget
	FROM [bag].[plan_values_prod_sum] WITH (NOLOCK)
	) c ON LEFT(a.shiftid, 4) = c.shiftdate

