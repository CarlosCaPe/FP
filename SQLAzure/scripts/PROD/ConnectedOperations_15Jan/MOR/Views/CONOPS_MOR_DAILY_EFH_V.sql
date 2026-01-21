CREATE VIEW [MOR].[CONOPS_MOR_DAILY_EFH_V] AS

--SELECT * FROM [MOR].[CONOPS_MOR_DAILY_EFH_V] where shiftflag = 'curr'
CREATE VIEW [MOR].[CONOPS_MOR_DAILY_EFH_V]
AS

WITH EFH_Target AS(
SELECT TOP 1
	substring(replace(DateEffective,'-',''),3,4) as shiftdate,
	EquivalentFlatHaul as EFHShifttarget
FROM [mor].[plan_values_prod_sum] with (nolock)
ORDER BY DateEffective DESC
),

ShiftEFH AS(
SELECT 
	site_code,
	b.SHIFTFLAG,
	avg(distloaded + (fliftup * 27.1428) + (fliftdown * 16)) AS ShiftEFH
FROM dbo.delta_c a with (nolock) 
LEFT JOIN MOR.CONOPS_MOR_EOS_SHIFT_INFO_V b
	ON a.shiftindex = b.SHIFTINDEX
WHERE SITE_CODE = 'MOR'
group by site_code, b.SHIFTFLAG
),

HourlyEFH AS(
	SELECT 
		site_code,
		shiftindex,
		DUMP_HOS,
		DATEADD(HOUR, DUMP_HOS, START_DATE_TS) AS BreakByHour,
		avg(distloaded + (fliftup * 27.1428) + (fliftdown * 16)) AS EFH
	FROM dbo.delta_c with (nolock)
	WHERE SITE_CODE = 'MOR'
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
RIGHT JOIN [MOR].[CONOPS_MOR_EOS_SHIFT_INFO_V] b
	ON a.SHIFTINDEX = b.SHIFTINDEX
LEFT JOIN ShiftEFH c
	ON b.SHIFTFLAG = c.SHIFTFLAG
LEFT JOIN EFH_Target t
	ON 1=1
WHERE BreakByHour IS NOT NULL


