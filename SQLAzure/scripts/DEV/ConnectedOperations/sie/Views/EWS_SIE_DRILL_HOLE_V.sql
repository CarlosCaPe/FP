CREATE VIEW [sie].[EWS_SIE_DRILL_HOLE_V] AS



--select * from [sie].[EWS_SIE_DRILL_HOLE_V]

CREATE VIEW [sie].[EWS_SIE_DRILL_HOLE_V]
AS


SELECT 
shiftflag,
siteflag,
dateadd(hour, datediff(hour, 0, [END_HOLE_TS]), 0) as TimeStampHour,
Count(DISTINCT(HOLENUMBER)) AS countHoles
FROM [sie].[CONOPS_SIE_SHIFT_INFO_V] a
LEFT JOIN [dbo].[FR_DRILLING_SCORES] b WITH (NOLOCK)
ON a.shiftindex = b.SHIFTINDEX AND b.SITE_CODE = 'SIE'
GROUP BY
shiftflag,
siteflag,
dateadd(hour, datediff(hour, 0, [END_HOLE_TS]), 0) 



