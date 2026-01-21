CREATE VIEW [BAG].[CONOPS_BAG_EOS_SHOVEL_SUMMARY_V] AS




--SELECT * FROM [BAG].[CONOPS_BAG_EOS_SHOVEL_SUMMARY_V] WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [bag].[CONOPS_BAG_EOS_SHOVEL_SUMMARY_V]  
AS  

WITH LH_LOAD AS(
SELECT 
	SHIFTINDEX,
	SITE_CODE,
	EXCAV as ShovelId,
	CASE WHEN LEFT(LOC,4) BETWEEN '0000' AND '9999' THEN SUBSTRING(LOC,6,2) ELSE LOC END AS PushBack,
	loadtons_us AS loadtons,
	spottime AS SpotSec,
	loadingtim AS LoadingSec,
	idletime + hangtime AS QueueSec,
	hangtime AS HangTimeSec,
	CASE WHEN MEASURETON >= (SELECT PayloadFilterLower FROM dbo.PAYLOAD_FILTER WHERE SITEFLAG = 'BAG') THEN MEASURETON ELSE NULL END AS Payload
FROM [dbo].[LH_LOAD] WITH (NOLOCK)
WHERE site_code='BAG'
),

ShovelLoad AS(
SELECT
	SHIFTINDEX,
	SITE_CODE,
	ShovelId,
	PushBack,
	SUM(loadtons) AS loadtons,
	AVG(SpotSec) AS SpotSec,
	AVG(LoadingSec) AS LoadingSec,
	AVG(QueueSec) AS QueueSec,
	AVG(HangTimeSec) AS HangTimeSec,
	AVG(Payload) AS Payload
FROM LH_LOAD
GROUP BY SHIFTINDEX, SITE_CODE, ShovelId, PushBack
),

ShovelDuration AS(
SELECT
	SHIFTINDEX,
	SHIFTID,
	SITE_CODE,
	EQMT,
	PushBack,
	SUM(ReadySec) AS ReadySec,
	SUM(DelaySec) AS DelaySec
FROM(
	SELECT
		SHIFTINDEX,
		SHIFTID,
		SITE_CODE,
		EQMT,
		CASE WHEN LEFT(LOC,4) BETWEEN '0000' AND '9999' THEN SUBSTRING(LOC,6,2) ELSE LOC END AS PushBack,
		CASE WHEN CATEGORY IN (1,2) THEN SUM(DURATION) END AS ReadySec,
		CASE WHEN CATEGORY = 6 THEN SUM(DURATION) END AS DelaySec
	FROM bag.fleet_equipment_hourly_status with(nolock)
	WHERE UNIT = 2
		AND LOC IS NOT NULL
		AND CATEGORY IN (1,2,6)
	GROUP BY SHIFTINDEX, SHIFTID, SITE_CODE, EQMT, LOC, CATEGORY
) a
GROUP BY SHIFTINDEX, SHIFTID, SITE_CODE, EQMT, PushBack
),

ShovelSummary AS(
SELECT
	s.SHIFTFLAG,
	s.siteflag,
	ShovelId,
	sl.Pushback,
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
RIGHT JOIN ShovelDuration sd
	ON sl.SHIFTINDEX = sd.SHIFTINDEX
	AND sl.ShovelId = sd.EQMT
	AND sl.PushBack = sd.PushBack
RIGHT JOIN [BAG].[CONOPS_BAG_SHIFT_INFO_V] s
	ON sl.SHIFTINDEX = s.SHIFTINDEX
GROUP BY
	s.SHIFTFLAG,
	s.siteflag,
	ShovelId,
	sl.Pushback
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
LEFT JOIN bag.CONOPS_BAG_SHOVEL_INFO_V b
	ON a.SHIFTFLAG = b.SHIFTFLAG
	AND a.ShovelId = b.ShovelId
LEFT JOIN bag.CONOPS_BAG_SHOVEL_ASSET_EFFICIENCY_PER_SHOVEL_V c
	ON a.SHIFTFLAG = c.SHIFTFLAG
	AND a.ShovelId = c.eqmt


