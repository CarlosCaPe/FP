CREATE VIEW [SAF].[CONOPS_SAF_SHIFT_TARGET_V] AS



--select * from [saf].[CONOPS_SAF_SHIFT_TARGET_V]

CREATE VIEW [saf].[CONOPS_SAF_SHIFT_TARGET_V]
AS

WITH shiftTonTarget AS (
	SELECT Right([Year], 2) + FORMAT(CAST([Month] AS numeric), '00') +
			     FORMAT(CAST([Day] AS numeric), '00') + FORMAT(CAST(SHIFT_CODE AS numeric), '000') [ShiftId],
		   --siteflag,
		   TOTALMINETPD AS ShiftTarget
	FROM (
		SELECT DATEEFFECTIVE,
			   REVERSE(PARSENAME(REPLACE(REVERSE(DATEEFFECTIVE), '-', '.'), 1)) AS [Year],
			   REVERSE(PARSENAME(REPLACE(REVERSE(DATEEFFECTIVE), '-', '.'), 2)) AS [Month],
			   REVERSE(PARSENAME(REPLACE(REVERSE(DATEEFFECTIVE), '-', '.'), 3)) AS [Day],
			   Shiftindex AS [SHIFT_CODE],
			   --'SAF' AS siteflag,
			   TOTALMINETPD
		FROM [saf].[PLAN_VALUES] (nolock)
	) a
)

SELECT xx.siteflag,
       xx.shiftflag,
       CAST(xx.shiftid AS numeric) AS shiftid,
       xx.ShiftTarget,
       CASE
           WHEN xx.ShiftCompleteHour IS NULL THEN xx.ShiftTarget
           ELSE cast((xx.ShiftCompleteHour/12.0)*xx.ShiftTarget AS integer)
       END AS TargetValue,
       xx.EFHTarget AS EFHShiftTarget,
       CASE
           WHEN xx.ShiftCompleteHour IS NULL THEN xx.EFHTarget
           ELSE cast((xx.ShiftCompleteHour/12.0)*xx.EFHTarget AS integer)
       END AS EFHTarget
FROM (
   SELECT a.siteflag,
          a.shiftflag,
          a.shiftid,
          b.ShiftStartDateTime,
          b.ShiftEndDateTime,
          dateadd(HOUR, c.site_offset_hour, GETUTCDATE()) AS current_local_time,
          CASE
              WHEN a.shiftflag = 'PREV' THEN datediff(HOUR, b.ShiftStartDateTime, b.ShiftEndDateTime)
              WHEN a.shiftflag = 'CURR' THEN datediff(HOUR, b.ShiftStartDateTime, dateadd(HOUR, c.site_offset_hour, GETUTCDATE()))
              ELSE NULL
          END AS ShiftCompleteHour,
          d.ShiftTarget,
          e.EFHTarget
   FROM [saf].[CONOPS_SAF_SHIFT_INFO_V] a (NOLOCK)
   LEFT JOIN (
	  SELECT shiftid,
             ShiftStartDateTime,
             LEAD(ShiftStartDateTime) OVER (
                                            ORDER BY shiftid) AS ShiftEndDateTime
      FROM [saf].[shift_info] (NOLOCK)
   ) b ON a.shiftid = b.shiftid AND a.siteflag = 'SAF'
   LEFT JOIN (
	  SELECT site_code,
             site_offset_hour
      FROM [dbo].[opsportal_site] (NOLOCK)
	  ) c ON a.siteflag = c.site_code AND a.siteflag = 'SAF'
   LEFT JOIN shiftTonTarget d ON a.shiftid = d.ShiftId 
   LEFT JOIN [saf].[CONOPS_SAF_DELTA_C_TARGET_V] e WITH (NOLOCK) ON a.shiftid = e.ShiftId AND a.siteflag = e.siteflag
) XX
WHERE xx.siteflag = 'SAF'


