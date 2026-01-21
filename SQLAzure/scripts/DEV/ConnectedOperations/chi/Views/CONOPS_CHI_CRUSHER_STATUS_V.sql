CREATE VIEW [chi].[CONOPS_CHI_CRUSHER_STATUS_V] AS


--SELECT * FROM [CHI].[CONOPS_CHI_CRUSHER_STATUS_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [CHI].[CONOPS_CHI_CRUSHER_STATUS_V]  
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
		CASE WHEN eqmt = 'CRUSHER-AUX' THEN 'CRUSHER'
			ELSE eqmt 
			END AS Crusher,
		"Status",
		reasons,
		StartDateTime,
		EndDateTime,
		ROW_NUMBER() OVER (PARTITION BY siteflag, shiftid, eqmt ORDER BY StartDateTime DESC) num
	FROM CHI.asset_efficiency WITH (NOLOCK)
	WHERE eqmt IN ('CRUSHER-AUX')
) x
LEFT JOIN CHI.CONOPS_CHI_SHIFT_INFO_V s
	ON x.shiftid = s.shiftid
WHERE x.num = 1
AND s.shiftflag IS NOT NULL