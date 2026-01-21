CREATE VIEW [saf].[EWS_SAF_DRILL_HOLE_V] AS



--select * from [saf].[EWS_SAF_DRILL_HOLE_V]

CREATE VIEW [saf].[EWS_SAF_DRILL_HOLE_V]
AS


SELECT 
shiftflag,
siteflag,
dateadd(hour, datediff(hour, 0, [END_HOLE_TS]), 0) as TimeStampHour,
Count(DISTINCT(HOLENUMBER)) AS countHoles
FROM [saf].[CONOPS_SAF_SHIFT_INFO_V] a
LEFT JOIN [dbo].[FR_DRILLING_SCORES] b WITH (NOLOCK)
ON a.shiftindex = b.SHIFTINDEX AND b.SITE_CODE = 'SAF'
GROUP BY
shiftflag,
siteflag,
dateadd(hour, datediff(hour, 0, [END_HOLE_TS]), 0) 



