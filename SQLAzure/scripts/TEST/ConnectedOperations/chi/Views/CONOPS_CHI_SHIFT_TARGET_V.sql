CREATE VIEW [chi].[CONOPS_CHI_SHIFT_TARGET_V] AS



--select * from [chi].[CONOPS_CHI_SHIFT_TARGET_V]
CREATE VIEW [chi].[CONOPS_CHI_SHIFT_TARGET_V]
AS

WITH shiftTonTarget AS (
	SELECT --siteflag,
		   CAST(Right([Year], 2) + FORMAT(CAST([Month] AS numeric), '00') AS numeric) [ShiftId],
		   [target] AS ShiftTarget
	FROM (
		SELECT  --'CHI' siteflag,
				REVERSE(PARSENAME(REPLACE(REVERSE(DATEEFFECTIVE), '-', '.'), 1)) AS [Year],
				REVERSE(PARSENAME(REPLACE(REVERSE(DATEEFFECTIVE), '-', '.'), 2)) AS [Month],
				(ISNULL([TotalExPitTPD], 0) + ISNULL([OreRehandletoCrusherTPD], 0)) / 2 as [target]
		FROM CHI.PLAN_VALUES tgt WITH (NOLOCK)
		INNER JOIN (
			SELECT MAX(DATEEFFECTIVE) MaxDateEffective
			FROM [chi].[PLAN_VALUES] WITH (NOLOCK)
			WHERE GETDATE() >= DateEffective 
		 ) [maxdate] ON tgt.DateEffective = [maxdate].MaxDateEffective
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
   FROM [chi].[CONOPS_CHI_SHIFT_INFO_V] a (NOLOCK)
   LEFT JOIN (
	  SELECT shiftid,
             ShiftStartDateTime,
             LEAD(ShiftStartDateTime) OVER ( ORDER BY shiftid) AS ShiftEndDateTime
      FROM [chi].[shift_info] (NOLOCK)
   ) b ON a.shiftid = b.shiftid AND a.siteflag = 'CHI'
   LEFT JOIN (
	  SELECT site_code,
             site_offset_hour
      FROM [dbo].[opsportal_site] (NOLOCK)
	  ) c ON a.siteflag = c.site_code AND a.siteflag = 'CHI'
   LEFT JOIN shiftTonTarget d ON LEFT(a.shiftid, 4) >= d.ShiftId 
   LEFT JOIN [chi].[CONOPS_CHI_DELTA_C_TARGET_V] e WITH (NOLOCK) ON LEFT(a.shiftid, 4) >= e.ShiftId AND a.siteflag = e.siteflag
) XX
WHERE xx.siteflag = 'CHI'


