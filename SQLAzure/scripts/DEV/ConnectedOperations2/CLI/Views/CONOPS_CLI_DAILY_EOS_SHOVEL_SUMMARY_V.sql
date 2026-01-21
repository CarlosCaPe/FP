CREATE VIEW [CLI].[CONOPS_CLI_DAILY_EOS_SHOVEL_SUMMARY_V] AS





--SELECT * FROM [CLI].[CONOPS_CLI_DAILY_EOS_SHOVEL_SUMMARY_V] WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [CLI].[CONOPS_CLI_DAILY_EOS_SHOVEL_SUMMARY_V]  
AS  
  
WITH ShovelLoad AS(
SELECT 
	SHIFTINDEX,
	SITE_CODE,
	EXCAV as ShovelId,
	CASE WHEN LOC LIKE '%11400%'
		THEN 'INPIT'
		ELSE 'EXPIT'
	END AS PushBack,
	loadtons_us AS loadtons,
	EX_TMCAT01 + EX_TMCAT02 AS ReadySec,
	EX_TMCAT06 AS DelaySec,
	spottime AS SpotSec,
	loadingtim AS LoadingSec,
	idletime + hangtime AS QueueSec,
	hangtime AS HangTimeSec,
	CASE WHEN MEASURETON >= (SELECT PayloadFilterLower FROM dbo.PAYLOAD_FILTER WHERE SITEFLAG = 'CLI') THEN MEASURETON ELSE NULL END AS Payload
FROM [dbo].[LH_LOAD] WITH (NOLOCK)
WHERE site_code='CLI'
),

ShovelSummary AS(
SELECT
	s.SHIFTFLAG,
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
RIGHT JOIN [CLI].[CONOPS_CLI_EOS_SHIFT_INFO_V] s
	ON sl.SHIFTINDEX = s.SHIFTINDEX
GROUP BY
	s.SHIFTFLAG,
	s.siteflag,
	ShovelId,
	Pushback
),

ShovelOperator AS(
SELECT 
	shiftflag,
	shiftid,
	ShovelId,
	Operator,
	OperatorId,
	OperatorImageURL,
	ROW_NUMBER() OVER(PARTITION BY shiftflag, shovelid ORDER BY shiftid DESC) AS rn
FROM CLI.CONOPS_CLI_DAILY_SHOVEL_INFO_V
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
LEFT JOIN ShovelOperator b
	ON b.rn = 1
	AND a.SHIFTFLAG = b.SHIFTFLAG
	AND a.ShovelId = b.ShovelId
LEFT JOIN CLI.CONOPS_CLI_DAILY_SHOVEL_ASSET_EFFICIENCY_PER_SHOVEL_V c
	ON a.shiftflag = c.shiftflag
	AND a.ShovelId = c.eqmt
WHERE b.rn = 1




