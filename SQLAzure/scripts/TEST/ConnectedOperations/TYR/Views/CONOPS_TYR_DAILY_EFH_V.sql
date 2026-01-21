CREATE VIEW [TYR].[CONOPS_TYR_DAILY_EFH_V] AS


--SELECT * FROM [tyr].[CONOPS_TYR_DAILY_EFH_V] where shiftflag = 'curr'
CREATE VIEW [TYR].[CONOPS_TYR_DAILY_EFH_V]
AS



WITH ShiftEFH AS(
SELECT 
	site_code,
	b.SHIFTFLAG,
	avg(distloaded + (fliftup * 27.1428) + (fliftdown * 16)) AS ShiftEFH
FROM dbo.delta_c a with (nolock) 
LEFT JOIN TYR.CONOPS_TYR_EOS_SHIFT_INFO_V b
	ON a.shiftindex = b.SHIFTINDEX
WHERE SITE_CODE = 'TYR'
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
	WHERE SITE_CODE = 'TYR'
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
	EFHtarget AS EFHShifttarget,
	c.ShiftEFH
FROM HourlyEFH a WITH (NOLOCK)
RIGHT JOIN [TYR].[CONOPS_TYR_EOS_SHIFT_INFO_V] b
	ON a.SHIFTINDEX = b.SHIFTINDEX
LEFT JOIN ShiftEFH c
	ON b.SHIFTFLAG = c.SHIFTFLAG
LEFT JOIN [tyr].[CONOPS_TYR_DELTA_C_TARGET_V] t
	ON b.shiftid = t.shiftid
WHERE BreakByHour IS NOT NULL

