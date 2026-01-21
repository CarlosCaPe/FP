CREATE VIEW [SAF].[CONOPS_SAF_CRUSHER_STATUS_V] AS



--SELECT * FROM [SAF].[CONOPS_SAF_CRUSHER_STATUS_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [SAF].[CONOPS_SAF_CRUSHER_STATUS_V]  
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
		CASE WHEN eqmt = 'PC001' THEN 'CRUSHER'
			ELSE eqmt 
			END AS Crusher,
		"Status",
		reasons,
		StartDateTime,
		EndDateTime,
		ROW_NUMBER() OVER (PARTITION BY siteflag, shiftid, eqmt ORDER BY StartDateTime DESC) num
	FROM SAF.asset_efficiency WITH (NOLOCK)
	WHERE eqmt IN ('PC001')
) x
LEFT JOIN SAF.CONOPS_SAF_SHIFT_INFO_V s
	ON x.shiftid = s.shiftid
WHERE x.num = 1
AND s.shiftflag IS NOT NULL

