CREATE VIEW [bag].[CONOPS_BAG_DAILY_EOS_SHOVEL_SUMMARY_V] AS

--SELECT * FROM [BAG].[CONOPS_BAG_DAILY_EOS_SHOVEL_SUMMARY_V] WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [BAG].[CONOPS_BAG_DAILY_EOS_SHOVEL_SUMMARY_V]  
AS
  
WITH LH_LOAD AS(
SELECT
	shift_id_co,
	SECONDARYMACHINENAME AS ShovelId,
	CASE WHEN LEFT(SOURCELOCATIONNAME,4) BETWEEN '0000' AND '9999' 
		THEN SUBSTRING(SOURCELOCATIONNAME,6,2) ELSE SOURCELOCATIONNAME END AS PushBack,
	REPORT_PAYLOAD_SHORT_TONS AS LoadTons,
	CASE WHEN PayloadFilter = 1
		THEN MEASURED_PAYLOAD_SHORT_TONS ELSE NULL END AS Payload,
	T_SpottingAtSource AS SpotSec,
	T_Loading AS LoadingSec,
	T_QueuingAtSource AS QueueSec,
	S_HangTime AS HangTimeSec
FROM BAG.FLEET_CYCLE_COMPONENT_DURATION_V
),

ShovelLoad AS(
SELECT
	shift_id_co,
	ShovelId,
	PushBack,
	SUM(loadtons) AS loadtons,
	AVG(SpotSec) AS SpotSec,
	AVG(LoadingSec) AS LoadingSec,
	AVG(QueueSec) AS QueueSec,
	AVG(HangTimeSec) AS HangTimeSec,
	AVG(Payload) AS Payload
FROM LH_LOAD
GROUP BY shift_id_co, ShovelId, PushBack
),

ShovelDuration AS(
SELECT
	SHIFTINDEX,
	SITE_CODE,
	EQMT,
	PushBack,
	SUM(ReadySec) AS ReadySec,
	SUM(DelaySec) AS DelaySec
FROM(
	SELECT
		SHIFTINDEX,
		SITE_CODE,
		EQMT,
		CASE WHEN LEFT(LOC,4) BETWEEN '0000' AND '9999' THEN SUBSTRING(LOC,6,2) ELSE LOC END AS PushBack,
		CASE WHEN CATEGORY IN (1,2) THEN SUM(DURATION) END AS ReadySec,
		CASE WHEN CATEGORY = 6 THEN SUM(DURATION) END AS DelaySec
	FROM bag.equipment_hourly_status with(nolock)
	WHERE UNIT = 2
		AND LOC IS NOT NULL
		AND CATEGORY IN (1,2,6)
	GROUP BY SHIFTINDEX, SITE_CODE, EQMT, LOC, CATEGORY
) a
GROUP BY SHIFTINDEX, SITE_CODE, EQMT, PushBack
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
FROM bag.CONOPS_BAG_DAILY_SHOVEL_INFO_V
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
RIGHT JOIN [BAG].[CONOPS_BAG_EOS_SHIFT_INFO_V] s
	ON sl.shift_id_co = s.shiftid
RIGHT JOIN ShovelDuration sd
	ON s.SHIFTINDEX = sd.SHIFTINDEX
	AND sl.ShovelId = sd.EQMT
	AND sl.PushBack = sd.PushBack
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
LEFT JOIN ShovelOperator b
	ON b.rn = 1
	AND a.SHIFTFLAG = b.SHIFTFLAG
	AND a.ShovelId = b.ShovelId
LEFT JOIN bag.CONOPS_BAG_DAILY_SHOVEL_ASSET_EFFICIENCY_PER_SHOVEL_V c
	ON a.shiftflag = c.shiftflag
	AND a.ShovelId = c.eqmt

