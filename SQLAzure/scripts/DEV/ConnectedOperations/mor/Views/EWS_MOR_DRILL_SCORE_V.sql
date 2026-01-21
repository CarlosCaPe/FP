CREATE VIEW [mor].[EWS_MOR_DRILL_SCORE_V] AS



--select * from [mor].[EWS_MOR_DRILL_SCORE_V]

CREATE VIEW [mor].[EWS_MOR_DRILL_SCORE_V]
AS


SELECT 
shiftflag,
siteflag,
[DATE] AS currentDate,
AVG([HOLETIME]) AS avgHoleTime,
AVG([OVERALLSCORE]) AS avgOverallScore,
AVG([DEPTHSCORE]) AS avgDepthScore,
AVG([HORSCORE]) AS avgHorScore,
AVG([PENRATE]) AS avgPenRate
FROM [mor].[CONOPS_MOR_SHIFT_INFO_V] a
LEFT JOIN [dbo].[FR_DRILLING_SCORES] b WITH (NOLOCK)
ON a.shiftindex = b.SHIFTINDEX AND b.SITE_CODE = 'MOR'
GROUP BY
shiftflag,
siteflag,
[DATE]



