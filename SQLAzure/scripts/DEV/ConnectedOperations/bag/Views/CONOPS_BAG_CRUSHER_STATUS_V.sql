CREATE VIEW [bag].[CONOPS_BAG_CRUSHER_STATUS_V] AS


--SELECT * FROM [BAG].[CONOPS_BAG_CRUSHER_STATUS_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [BAG].[CONOPS_BAG_CRUSHER_STATUS_V]  
AS  

SELECT
	x.siteflag,
	s.shiftflag,
	s.shiftindex,
	x.Crusher,
	x.Status,
	x.reasons,
	NULL AS ShovelId,
	x.StartDateTime AS StartTime
FROM(
	SELECT
		siteflag,
		shiftid,
		CASE WHEN eqmt IN ('CR2') THEN 'Crusher 2'
			ELSE eqmt 
			END AS Crusher,
		"Status",
		reasons,
		StartDateTime,
		EndDateTime,
		ROW_NUMBER() OVER (PARTITION BY siteflag, shiftid, eqmt ORDER BY StartDateTime DESC) num
	FROM bag.asset_efficiency WITH (NOLOCK)
	WHERE eqmt = 'CR2'
) x
LEFT JOIN BAG.CONOPS_BAG_SHIFT_INFO_V s
	ON x.shiftid = s.shiftid
WHERE x.num = 1
AND s.shiftflag IS NOT NULL

UNION

SELECT
	x.SITE_CODE AS siteflag,
	s.shiftflag,
	x.SHIFTINDEX,
	CASE WHEN x.DUMPNAME IN ('SMALL CR_T') THEN 'Small Crusher'
		ELSE x.DUMPNAME END AS Crusher,
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
	WHERE SITE_CODE = 'BAG'
		AND DUMPNAME LIKE 'SMALL CR%'
) x
LEFT JOIN BAG.CONOPS_BAG_SHOVEL_INFO_V s
	ON x.shiftindex = s.shiftindex
	AND x.ShovelId = s.ShovelID
WHERE x.num = 1
AND s.shiftflag IS NOT NULL