CREATE VIEW [bag].[CONOPS_BAG_SHIFT_TARGET_V] AS


--select * from [bag].[CONOPS_BAG_SHIFT_TARGET_V]

CREATE VIEW [BAG].[CONOPS_BAG_SHIFT_TARGET_V]
AS


SELECT xx.siteflag
	,xx.shiftflag
	,xx.shiftid
	,xx.ShiftTarget
	,CASE 
		WHEN xx.ShiftCompleteHour IS NULL
			THEN xx.ShiftTarget
		ELSE cast((xx.ShiftCompleteHour / 12.0) * xx.ShiftTarget AS INTEGER)
		END AS TargetValue
	,xx.EFHTarget AS EFHShiftTarget
	,CASE 
		WHEN xx.ShiftCompleteHour IS NULL
			THEN xx.EFHTarget
		ELSE cast((xx.ShiftCompleteHour / 12.0) * xx.EFHTarget AS INTEGER)
		END AS EFHTarget
FROM (
	SELECT a.siteflag
		,a.shiftflag
		,a.shiftid
		,b.ShiftStartDateTime
		,b.ShiftEndDateTime
		,dateadd(hour, c.site_offset_hour, GETUTCDATE()) AS current_local_time
		,CASE 
			WHEN a.shiftflag = 'PREV'
				THEN datediff(hour, b.ShiftStartDateTime, b.ShiftEndDateTime)
			WHEN a.shiftflag = 'CURR'
				THEN datediff(hour, b.ShiftStartDateTime, dateadd(hour, c.site_offset_hour, GETUTCDATE()))
			ELSE NULL
			END AS ShiftCompleteHour
		,d.ShiftTarget
		,e.EFHTarget
	FROM [bag].[CONOPS_BAG_SHIFT_INFO_V] a(NOLOCK)
	LEFT JOIN (
		SELECT shiftid
			,ShiftStartDateTime
			,LEAD(ShiftStartDateTime) OVER (
				ORDER BY shiftid
				) AS ShiftEndDateTime
		FROM [bag].[CONOPS_BAG_SHIFT_INFO_V](NOLOCK)
		) b ON a.shiftid = b.shiftid
	LEFT JOIN (
		SELECT site_code
			,site_offset_hour
		FROM [dbo].[opsportal_site](NOLOCK)
		) c ON a.siteflag = c.site_code
	LEFT JOIN (
		SELECT FORMATSHIFTID
			,cast(sum(TOTALMINED) AS INT) AS shifttarget
		FROM [bag].[plan_values] WITH (NOLOCK)
		GROUP BY FORMATSHIFTID
		) d ON a.shiftid = d.Formatshiftid
	LEFT JOIN (
		SELECT 
			FORMATSHIFTID,
			EFH as EFHTarget
		FROM [bag].[plan_values] with (nolock)
		) e ON a.shiftid = e.FORMATSHIFTID
	) XX


--group by siteflag,shiftflag,shiftid
--WHERE xx.siteflag = 'BAG'




