CREATE VIEW [cer].[CONOPS_CER_SHIFT_TARGET_V] AS






-- SELECT * FROM [cer].[CONOPS_CER_SHIFT_TARGET_V]

CREATE VIEW [cer].[CONOPS_CER_SHIFT_TARGET_V]
AS

WITH shiftTonTarget AS (
SELECT DISTINCT
Shiftid,
MaterialMinedShiftTarget AS ShiftTarget
FROM [cer].[CONOPS_CER_SHOVEL_TARGET_V]
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
   FROM [cer].[CONOPS_CER_SHIFT_INFO_V] a (NOLOCK)
   LEFT JOIN (
	  SELECT shiftid,
             ShiftStartDateTime,
             LEAD(ShiftStartDateTime) OVER (
                                            ORDER BY shiftid) AS ShiftEndDateTime
      FROM [cer].[shift_info] (NOLOCK)
   ) b ON a.shiftid = b.shiftid AND a.siteflag = 'CER'
   LEFT JOIN (
	  SELECT site_code,
             site_offset_hour
      FROM [dbo].[opsportal_site] (NOLOCK)
	  ) c ON a.siteflag = c.site_code AND a.siteflag = 'CER'
   LEFT JOIN shiftTonTarget d ON a.shiftid = d.ShiftId 
   LEFT JOIN [cer].[CONOPS_CER_DELTA_C_TARGET_V] e WITH (NOLOCK) ON a.shiftid = e.ShiftId AND a.siteflag = e.siteflag
) xx
WHERE xx.siteflag = 'CER'

