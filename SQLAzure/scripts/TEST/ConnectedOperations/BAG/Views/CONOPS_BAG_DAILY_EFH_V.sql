CREATE VIEW [BAG].[CONOPS_BAG_DAILY_EFH_V] AS

--SELECT * FROM [BAG].[CONOPS_BAG_DAILY_EFH_V] where shiftflag = 'curr'
CREATE VIEW [bag].[CONOPS_BAG_DAILY_EFH_V]
AS

WITH EFH_Target AS(
SELECT 
	FORMATSHIFTID,
	EFH as EFHShifttarget
FROM [bag].[plan_values] with (nolock)
),

ShiftEFH AS(
SELECT 
	site_code,
	b.SHIFTFLAG,
	avg(distloaded + (fliftup * 27.1428) + (fliftdown * 16)) AS ShiftEFH
FROM dbo.delta_c a with (nolock) 
LEFT JOIN bag.CONOPS_BAG_EOS_SHIFT_INFO_V b
	ON a.site_code = b.SITEFLAG
	AND a.shiftindex = b.SHIFTINDEX
WHERE SITE_CODE = 'BAG'
group by site_code, b.SHIFTFLAG
),

HourlyEFH AS(
	SELECT
		SITE_CODE,
		SHIFTINDEX,
		DUMP_HOS,
		DATEADD(HOUR, DUMP_HOS, START_DATE_TS) AS BreakByHour,
		avg(distloaded + (fliftup * 27.1428) + (fliftdown * 16)) AS EFH
	FROM(
		SELECT 
			SITE_CODE,
			SHIFTINDEX,
			START_DATE_TS,
			TIMEDUMP_TS,
			DATEDIFF(MINUTE,START_DATE_TS, TIMEDUMP_TS) / 60 AS DUMP_HOS,
			distloaded,
			fliftup,
			fliftdown
		FROM dbo.delta_c with (nolock)
		WHERE SITE_CODE = 'BAG'
	) a
	WHERE DUMP_HOS IS NOT NULL
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
	a.EFH,
	t.EFHShifttarget,
	c.ShiftEFH
FROM HourlyEFH a WITH (NOLOCK)
RIGHT JOIN [bag].[CONOPS_BAG_EOS_SHIFT_INFO_V] b
	ON a.SHIFTINDEX = b.SHIFTINDEX
LEFT JOIN ShiftEFH c
	ON b.SHIFTFLAG = c.SHIFTFLAG
LEFT JOIN EFH_Target t
	ON b.shiftid = t.FORMATSHIFTID
WHERE BreakByHour IS NOT NULL


