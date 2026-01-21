CREATE VIEW [bag].[CONOPS_BAG_EOS_SHOVEL_SUMMARY_V] AS

--SELECT * FROM [BAG].[CONOPS_BAG_EOS_SHOVEL_SUMMARY_V] WHERE SHIFTFLAG = 'CURR'
CREATE VIEW [bag].[CONOPS_BAG_EOS_SHOVEL_SUMMARY_V]
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
	ROUND(AVG(SpotSec) / 60.0 ,2) AS SpotTime_min,
	ROUND(AVG(LoadingSec) / 60.0 ,2) AS LoadingTime_min,
	ROUND(AVG(QueueSec) / 60.0 ,2) AS QueueTime_min,
	ROUND(AVG(HangTimeSec) / 60.0 ,2) AS HangTime_Min,
	AVG(Payload) AS Payload
FROM LH_LOAD
GROUP BY shift_id_co, ShovelId, PushBack
),

ShovelDuration AS(
SELECT
	SHIFTINDEX,
	SITE_CODE,
	EQMT,
	CASE WHEN LEFT(LOC,4) BETWEEN '0000' AND '9999' THEN SUBSTRING(LOC,6,2) ELSE LOC END AS PushBack,
	SUM(CASE WHEN CATEGORY IN (1,2) THEN DURATION ELSE 0 END) AS ReadySec,
	ROUND(SUM(CASE WHEN CATEGORY = 6 THEN DURATION ELSE 0 END) / 60.0 ,2) AS DelayDuration_min
FROM bag.equipment_hourly_status with(nolock)
WHERE UNIT = 2
	AND LOC IS NOT NULL
	AND CATEGORY IN (1,2,6)
GROUP BY SHIFTINDEX, SITE_CODE, EQMT, LOC
)

SELECT 
	a.SHIFTFLAG,
	a.siteflag,
	c.ShovelId,
	b.Pushback,
	c.Operator,
	c.OperatorId,
	c.OperatorImageURL,
	b.loadtons AS Tons,
	CASE WHEN ReadySec = 0 THEN 0
		ELSE ROUND(loadtons / (ReadySec/3600.00),2) END AS TPRH,
	b.SpotTime_min,
	b.LoadingTime_min,
	b.QueueTime_min,
	b.HangTime_Min,
	d.DelayDuration_min,
	NULL AS DelayReasons,
	b.Payload,
	e.availability_pct AS [Availability],
	e.use_of_availability_pct AS UseOfAvailability,
	e.ops_efficient_pct AS AssetEfficiency
FROM bag.conops_bag_shift_info_v a
LEFT JOIN ShovelLoad b
	ON a.shiftid = b.shift_id_co
LEFT JOIN bag.CONOPS_BAG_SHOVEL_INFO_V c
	ON a.shiftid = c.shiftid
	AND b.ShovelId = c.ShovelId
LEFT JOIN ShovelDuration d
	ON a.shiftindex = d.shiftindex
	AND b.ShovelId = d.EQMT
	AND b.Pushback = d.Pushback
LEFT JOIN bag.CONOPS_BAG_SHOVEL_ASSET_EFFICIENCY_PER_SHOVEL_V e
	ON a.shiftid = e.shiftid
	AND b.shovelid = e.eqmt

