CREATE VIEW [sie].[CONOPS_SIE_EFH_V] AS

--SELECT * FROM [SIE].[CONOPS_SIE_EFH_V] where shiftflag = 'curr'
CREATE VIEW [SIE].[CONOPS_SIE_EFH_V]
AS

WITH EFH_Target AS(
SELECT TOP 1
	substring(replace(cast(getdate() as date),'-',''),3,4) as shiftdate,
	EQUIVALENTFLATHAUL as EFHShifttarget
FROM [sie].[plan_values_prod_sum] WITH (NOLOCK)
ORDER BY DateEffective DESC
),

ShiftEFH AS(
SELECT 
	site_code,
	shiftindex,
	avg(distloaded + (fliftup * 27.1428) + (fliftdown * 16)) AS ShiftEFH
FROM dbo.delta_c with (nolock)
WHERE SITE_CODE = 'SIE'
group by site_code, shiftindex
),

HourlyEFH AS(
	SELECT 
		site_code,
		shiftindex,
		DUMP_HOS,
		DATEADD(HOUR, DUMP_HOS, START_DATE_TS) AS BreakByHour,
		avg(distloaded + (fliftup * 27.1428) + (fliftdown * 16)) AS EFH
	FROM dbo.delta_c with (nolock)
	WHERE SITE_CODE = 'SIE'
	GROUP BY SITE_CODE,
	SHIFTINDEX,
	DUMP_HOS,
	START_DATE_TS
)

SELECT
	b.siteflag,
	b.shiftflag,
	b.shiftindex,
	b.shiftid,
	b.ShiftStartDateTime,
	b.ShiftEndDateTime,
	a.BreakByHour,
	EFH,
	t.EFHShifttarget,
	c.ShiftEFH
FROM HourlyEFH a WITH (NOLOCK)
RIGHT JOIN [SIE].[CONOPS_SIE_SHIFT_INFO_V] b
	ON a.SHIFTINDEX = b.SHIFTINDEX
LEFT JOIN ShiftEFH c
	ON b.SHIFTINDEX = c.SHIFTINDEX
LEFT JOIN EFH_Target t
	ON 1=1
WHERE BreakByHour IS NOT NULL

