CREATE VIEW [cli].[EWS_CLI_DRILL_HOLE_V] AS



--select * from [cli].[EWS_CLI_DRILL_HOLE_V]

CREATE VIEW [cli].[EWS_CLI_DRILL_HOLE_V]
AS


SELECT 
shiftflag,
siteflag,
dateadd(hour, datediff(hour, 0, [END_HOLE_TS]), 0) as TimeStampHour,
Count(DISTINCT(HOLENUMBER)) AS countHoles
FROM [cli].[CONOPS_CLI_SHIFT_INFO_V] a
LEFT JOIN [dbo].[FR_DRILLING_SCORES] b WITH (NOLOCK)
ON a.shiftindex = b.SHIFTINDEX AND b.SITE_CODE = 'CLI'
GROUP BY
shiftflag,
siteflag,
dateadd(hour, datediff(hour, 0, [END_HOLE_TS]), 0) 



