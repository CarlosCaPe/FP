CREATE VIEW [CER].[CONOPS_CER_DAILY_EFH_V] AS

--SELECT * FROM [CER].[CONOPS_CER_DAILY_EFH_V] where shiftflag = 'curr'
CREATE VIEW [cer].[CONOPS_CER_DAILY_EFH_V]
AS

WITH ShiftEFH AS(
SELECT 
	site_code,
	b.SHIFTFLAG,
	avg(distloaded + (fliftup * 27.1428) + (fliftdown * 16)) AS ShiftEFH
FROM dbo.delta_c a with (nolock) 
LEFT JOIN cer.CONOPS_CER_EOS_SHIFT_INFO_V b
	ON a.site_code = b.SITEFLAG
	AND a.shiftindex = b.SHIFTINDEX
WHERE SITE_CODE = 'CER'
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
	WHERE SITE_CODE = 'CER'
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
	t.EFHtarget AS EFHShifttarget,
	c.ShiftEFH
FROM HourlyEFH a WITH (NOLOCK)
RIGHT JOIN [CER].[CONOPS_CER_EOS_SHIFT_INFO_V] b
	ON a.SHIFTINDEX = b.SHIFTINDEX
LEFT JOIN [CER].[CONOPS_CER_DELTA_C_TARGET_V] t
	ON b.shiftid = t.shiftid
LEFT JOIN ShiftEFH c
	ON b.SHIFTFLAG = c.SHIFTFLAG
WHERE BreakByHour IS NOT NULL

