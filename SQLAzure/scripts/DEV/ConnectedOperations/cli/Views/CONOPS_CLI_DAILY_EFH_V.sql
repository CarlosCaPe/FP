CREATE VIEW [cli].[CONOPS_CLI_DAILY_EFH_V] AS

--SELECT * FROM [CLI].[CONOPS_CLI_DAILY_EFH_V] where shiftflag = 'curr'
CREATE VIEW [cli].[CONOPS_CLI_DAILY_EFH_V]
AS

WITH EFH_Target AS(
SELECT TOP 1
	EFH as EFHShifttarget
FROM [cli].[plan_values] (nolock)
ORDER BY shiftid DESC
),

ShiftEFH AS(
SELECT 
	site_code,
	b.SHIFTFLAG,
	avg(distloaded + (fliftup * 27.1428) + (fliftdown * 16)) AS ShiftEFH
FROM dbo.delta_c a with (nolock) 
LEFT JOIN CLI.CONOPS_CLI_EOS_SHIFT_INFO_V b
	ON a.shiftindex = b.SHIFTINDEX
WHERE SITE_CODE = 'CLI'
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
	WHERE SITE_CODE = 'CLI'
	GROUP BY SITE_CODE,
	SHIFTINDEX,
	DUMP_HOS,
	START_DATE_TS
)

SELECT
	'CLI' AS siteflag,
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
RIGHT JOIN [CLI].[CONOPS_CLI_EOS_SHIFT_INFO_V] b
	ON a.SHIFTINDEX = b.SHIFTINDEX
LEFT JOIN ShiftEFH c
	ON b.SHIFTFLAG = c.SHIFTFLAG
LEFT JOIN EFH_Target t
	ON 1=1
WHERE BreakByHour IS NOT NULL

