CREATE VIEW [cer].[CONOPS_CER_CRUSHER_STATUS_V] AS




--SELECT * FROM [CER].[CONOPS_CER_CRUSHER_STATUS_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [cer].[CONOPS_CER_CRUSHER_STATUS_V]  
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
		CASE WHEN eqmt = 'HIDRO' THEN 'HIDROCHAN'
			WHEN eqmt = 'C1' THEN 'MILLCHAN'
			WHEN eqmt = 'C21' THEN 'MILLCRUSH1'
			WHEN eqmt = 'C22' THEN 'MILLCRUSH2'
			ELSE eqmt 
			END AS Crusher,
		"Status",
		reasons,
		StartDateTime,
		EndDateTime,
		ROW_NUMBER() OVER (PARTITION BY siteflag, shiftid, eqmt ORDER BY StartDateTime DESC) num
	FROM CER.asset_efficiency WITH (NOLOCK)
	WHERE eqmt IN ('HIDRO', 'C1', 'C21', 'C22')
) x
LEFT JOIN CER.CONOPS_CER_SHIFT_INFO_V s
	ON x.shiftid = s.shiftid
WHERE x.num = 1
AND s.shiftflag IS NOT NULL

