CREATE VIEW [CHI].[CONOPS_CHI_EOS_SHOVEL_SUMMARY_V] AS






--SELECT * FROM [CHI].[CONOPS_CHI_EOS_SHOVEL_SUMMARY_V] WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [CHI].[CONOPS_CHI_EOS_SHOVEL_SUMMARY_V]  
AS

WITH ShovelLoad AS(
SELECT 
	SHIFTINDEX,
	SITE_CODE,
	EXCAV as ShovelId,
	CASE WHEN LEFT(LOC,4) BETWEEN '0000' AND '9999' THEN SUBSTRING(grade,5, 2)
		ELSE LOC END AS PushBack,
	loadtons_us AS loadtons,
	EX_TMCAT01 + EX_TMCAT02 AS ReadySec,
	EX_TMCAT06 AS DelaySec,
	spottime AS SpotSec,
	loadingtim AS LoadingSec,
	idletime + hangtime AS QueueSec,
	hangtime AS HangTimeSec,
	CASE WHEN MEASURETON >= (SELECT PayloadFilterLower FROM dbo.PAYLOAD_FILTER WHERE SITEFLAG = 'CHI') THEN MEASURETON ELSE NULL END AS Payload
FROM [dbo].[LH_LOAD] WITH (NOLOCK)
WHERE site_code='CHI'
),

ShovelSummary AS(
SELECT
	s.SHIFTFLAG,
	s.shiftid,
	s.siteflag,
	ShovelId,
	Pushback,
	SUM(loadtons) AS Tons,
	CASE WHEN SUM(ReadySec) = 0 THEN 0
		ELSE ROUND(SUM(loadtons) / (SUM(ReadySec)/3600.00),2) END AS TPRH,
	ROUND(AVG(SpotSec) / 60.0 ,2) AS SpotTime_min,
	ROUND(AVG(LoadingSec) / 60.0, 2) AS LoadingTime_min,
	ROUND(AVG(QueueSec) / 60.0 ,2) AS QueueTime_min,
	ROUND(AVG(HangTimeSec) / 60.0 ,2) AS HangTime_Min,
	ROUND(SUM(DelaySec) / 60.0 ,2) AS DelayDuration_min,
	NULL AS DelayReasons,
	0 AS DelayCount,
	AVG(Payload) AS Payload
FROM ShovelLoad sl
RIGHT JOIN [CHI].[CONOPS_CHI_SHIFT_INFO_V] s
	ON sl.SHIFTINDEX = s.SHIFTINDEX
GROUP BY
	s.SHIFTFLAG,
	s.shiftid,
	s.siteflag,
	ShovelId,
	Pushback
)

SELECT 
	a.SHIFTFLAG,
	a.siteflag,
	a.ShovelId,
	a.Pushback,
	b.Operator,
	b.OperatorId,
	b.OperatorImageURL,
	a.Tons,
	a.TPRH,
	a.SpotTime_min,
	a.LoadingTime_min,
	a.QueueTime_min,
	a.HangTime_Min,
	a.DelayDuration_min,
	a.DelayReasons,
	a.Payload,
	c.availability_pct AS [Availability],
	c.use_of_availability_pct AS UseOfAvailability,
	c.ops_efficient_pct AS AssetEfficiency
FROM ShovelSummary a
LEFT JOIN CHI.CONOPS_CHI_SHOVEL_INFO_V b
	ON a.shiftid = b.shiftid
	AND a.ShovelId = b.ShovelId
LEFT JOIN CHI.CONOPS_CHI_SHOVEL_ASSET_EFFICIENCY_PER_SHOVEL_V c
	ON a.shiftid = c.shiftid
	AND a.ShovelId = c.eqmt







