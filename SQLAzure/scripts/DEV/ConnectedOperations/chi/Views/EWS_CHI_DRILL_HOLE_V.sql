CREATE VIEW [chi].[EWS_CHI_DRILL_HOLE_V] AS



--select * from [chi].[EWS_CHI_DRILL_HOLE_V]

CREATE VIEW [chi].[EWS_CHI_DRILL_HOLE_V]
AS


SELECT 
shiftflag,
siteflag,
dateadd(hour, datediff(hour, 0, [END_HOLE_TS]), 0) as TimeStampHour,
Count(DISTINCT(HOLENUMBER)) AS countHoles
FROM [chi].[CONOPS_CHI_SHIFT_INFO_V] a
LEFT JOIN [dbo].[FR_DRILLING_SCORES] b WITH (NOLOCK)
ON a.shiftindex = b.SHIFTINDEX AND b.SITE_CODE = 'CHI'
GROUP BY
shiftflag,
siteflag,
dateadd(hour, datediff(hour, 0, [END_HOLE_TS]), 0) 



