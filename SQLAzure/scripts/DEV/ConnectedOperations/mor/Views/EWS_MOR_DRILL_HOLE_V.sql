CREATE VIEW [mor].[EWS_MOR_DRILL_HOLE_V] AS



--select * from [mor].[EWS_MOR_DRILL_HOLE_V]

CREATE VIEW [mor].[EWS_MOR_DRILL_HOLE_V]
AS


SELECT 
shiftflag,
siteflag,
dateadd(hour, datediff(hour, 0, [END_HOLE_TS]), 0) as TimeStampHour,
Count(DISTINCT(HOLENUMBER)) AS countHoles
FROM [mor].[CONOPS_MOR_SHIFT_INFO_V] a
LEFT JOIN [dbo].[FR_DRILLING_SCORES] b WITH (NOLOCK)
ON a.shiftindex = b.SHIFTINDEX AND b.SITE_CODE = 'MOR'
GROUP BY
shiftflag,
siteflag,
dateadd(hour, datediff(hour, 0, [END_HOLE_TS]), 0)


