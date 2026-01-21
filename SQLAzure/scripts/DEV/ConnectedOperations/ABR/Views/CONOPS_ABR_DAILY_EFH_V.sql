CREATE VIEW [ABR].[CONOPS_ABR_DAILY_EFH_V] AS


--SELECT * FROM [abr].[CONOPS_ABR_DAILY_EFH_V] where shiftflag = 'curr'
CREATE VIEW [ABR].[CONOPS_ABR_DAILY_EFH_V]
AS



WITH ShiftEFH AS(
SELECT 
	site_code,
	b.SHIFTFLAG,
	avg(distloaded + (fliftup * 27.1428) + (fliftdown * 16)) AS ShiftEFH
FROM dbo.delta_c a with (nolock) 
LEFT JOIN ABR.CONOPS_ABR_EOS_SHIFT_INFO_V b
	ON a.shiftindex = b.SHIFTINDEX
WHERE SITE_CODE = 'ELA'
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
	WHERE SITE_CODE = 'ELA'
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
	--t.EFHShifttarget,
	EFHTarget AS EFHShifttarget,
	c.ShiftEFH
FROM HourlyEFH a WITH (NOLOCK)
RIGHT JOIN [ABR].[CONOPS_ABR_EOS_SHIFT_INFO_V] b
	ON a.SHIFTINDEX = b.SHIFTINDEX
LEFT JOIN ShiftEFH c
	ON b.SHIFTFLAG = c.SHIFTFLAG
LEFT JOIN [abr].[CONOPS_ABR_DELTA_C_TARGET_V] d
	ON b.shiftid = d.shiftid
WHERE BreakByHour IS NOT NULL

