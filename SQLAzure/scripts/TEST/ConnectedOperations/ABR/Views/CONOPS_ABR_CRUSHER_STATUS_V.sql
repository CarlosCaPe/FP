CREATE VIEW [ABR].[CONOPS_ABR_CRUSHER_STATUS_V] AS


--SELECT * FROM [abr].[CONOPS_ABR_CRUSHER_STATUS_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [ABR].[CONOPS_ABR_CRUSHER_STATUS_V]  
AS  

SELECT
	x.SITE_CODE AS siteflag,
	s.shiftflag,
	x.SHIFTINDEX,
	x.DUMPNAME AS Crusher,
	s.StatusName AS Status,
	s.ReasonDesc AS reasons,
	x.ShovelId,
	x.TIMEDUMP_TS AS StartTime
FROM(
	SELECT
		SITE_CODE,
		SHIFTINDEX,
		EXCAV AS ShovelId,
		DUMPNAME,
		TIMEDUMP_TS,
		ROW_NUMBER() OVER (PARTITION BY SITE_CODE, SHIFTINDEX ORDER BY TIMEDUMP_TS DESC) num
	FROM dbo.delta_c WITH (NOLOCK)
	WHERE SITE_CODE = 'ELA'
		AND DUMPNAME IN ('C.1')
) x
LEFT JOIN [abr].[CONOPS_ABR_SHOVEL_INFO_V] s
	ON x.shiftindex = s.shiftindex
	AND x.ShovelId = s.ShovelID
WHERE x.num = 1
AND s.shiftflag IS NOT NULL
