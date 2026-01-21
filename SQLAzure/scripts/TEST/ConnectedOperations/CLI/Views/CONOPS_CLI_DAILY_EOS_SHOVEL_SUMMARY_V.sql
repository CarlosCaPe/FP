CREATE VIEW [CLI].[CONOPS_CLI_DAILY_EOS_SHOVEL_SUMMARY_V] AS

--SELECT * FROM [CLI].[CONOPS_CLI_DAILY_EOS_SHOVEL_SUMMARY_V] WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [CLI].[CONOPS_CLI_DAILY_EOS_SHOVEL_SUMMARY_V]  
AS  
  
WITH ShovelLoad AS(
SELECT 
	s.shiftflag,
	sl.SiteFlag,
	EXCAV as ShovelId,
	CASE WHEN LOC LIKE '%11400%'
		THEN 'INPIT'
		ELSE 'EXPIT'
	END AS PushBack,
	FieldLSizeTons AS Loadtons,
	CASE WHEN PayloadFilter = 1
		THEN FieldTons ELSE NULL
	END AS Payload
FROM CLI.SHIFT_LOAD_DETAIL_V sl WITH (NOLOCK)
RIGHT JOIN [CLI].[CONOPS_CLI_EOS_SHIFT_INFO_V] s
	ON sl.shiftid = s.shiftid
),

LH_LOAD AS(
SELECT 
	s.shiftflag,
	SITE_CODE,
	EXCAV as ShovelId,
	CASE WHEN LOC LIKE '%11400%'
		THEN 'INPIT'
		ELSE 'EXPIT'
	END AS PushBack,
	EX_TMCAT01 + EX_TMCAT02 AS ReadySec,
	EX_TMCAT06 AS DelaySec,
	spottime AS SpotSec,
	loadingtim AS LoadingSec,
	idletime + hangtime AS QueueSec,
	hangtime AS HangTimeSec
FROM [dbo].[LH_LOAD] ll WITH (NOLOCK)
RIGHT JOIN [CLI].[CONOPS_CLI_EOS_SHIFT_INFO_V] s
	ON ll.SHIFTINDEX = s.SHIFTINDEX
WHERE site_code='CLI'
),

ShovelLoadSUM AS(
SELECT
	ShiftFlag,
	SiteFlag,
	ShovelId,
	Pushback,
	SUM(loadtons) AS Tons,
	AVG(Payload) AS Payload
FROM ShovelLoad
GROUP BY ShiftFlag, SiteFlag, ShovelId, Pushback
),

LH_LOAD_SUM AS(
SELECT
	ShiftFlag,
	ShovelId,
	Pushback,
	SUM(ReadySec) AS ReadySec,
	AVG(SpotSec) AS SpotSec,
	AVG(LoadingSec) AS LoadingSec,
	AVG(QueueSec) AS QueueSec,
	AVG(HangTimeSec) AS HangTimeSec,
	SUM(DelaySec) AS DelaySec
FROM LH_LOAD
GROUP BY ShiftFlag, ShovelId, Pushback
),

ShovelSummary AS(
SELECT
	sl.SHIFTFLAG,
	sl.siteflag,
	sl.ShovelId,
	sl.Pushback,
	Tons,
	CASE WHEN ReadySec = 0 THEN 0
		ELSE ROUND(Tons / (ReadySec/3600.00),2) END AS TPRH,
	ROUND(SpotSec / 60.0 ,2) AS SpotTime_min,
	ROUND(LoadingSec / 60.0, 2) AS LoadingTime_min,
	ROUND(QueueSec / 60.0 ,2) AS QueueTime_min,
	ROUND(HangTimeSec / 60.0 ,2) AS HangTime_Min,
	ROUND(DelaySec / 60.0 ,2) AS DelayDuration_min,
	NULL AS DelayReasons,
	0 AS DelayCount,
	Payload
FROM ShovelLoadSUM sl
LEFT JOIN LH_LOAD_SUM ll
	ON sl.ShiftFlag = ll.ShiftFlag
	AND sl.ShovelId = ll.ShovelId
	AND sl.PushBack = ll.PushBack
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

