CREATE VIEW [ABR].[CONOPS_ABR_DAILY_EOS_SHOVEL_SUMMARY] AS

--SELECT * FROM [ABR].[CONOPS_ABR_DAILY_EOS_SHOVEL_SUMMARY] WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [ABR].[CONOPS_ABR_DAILY_EOS_SHOVEL_SUMMARY]  
AS  
  
WITH ShovelLoad AS(
SELECT 
	SHIFTINDEX,
	SITE_CODE,
	EXCAV as ShovelId,
	SUBSTRING(LOC,5,4) AS PushBack,
	loadtons_us AS loadtons,
	EX_TMCAT01 + EX_TMCAT02 AS ReadySec,
	EX_TMCAT06 AS DelaySec,
	spottime AS SpotSec,
	loadingtim AS LoadingSec,
	idletime + hangtime AS QueueSec,
	hangtime AS HangTimeSec
FROM [dbo].[LH_LOAD] WITH (NOLOCK)
WHERE site_code='ELA'
)

SELECT
	s.SHIFTFLAG,
	s.siteflag,
	ShovelId,
	Pushback,
	SUM(loadtons) AS Tons,
	CASE WHEN SUM(ReadySec) = 0 THEN 0
		ELSE ROUND(SUM(loadtons) / (SUM(ReadySec)/3600.00),2) END AS TPRH,
	ROUND(SUM(SpotSec) / 60.0 ,2) AS SpotTime_min,
	ROUND(SUM(LoadingSec) / 60.0, 2) AS LoadingTime_min,
	ROUND(SUM(QueueSec) / 60.0 ,2) AS QueueTime_min,
	ROUND(SUM(HangTimeSec) / 60.0 ,2) AS HangTime_Min,
	ROUND(SUM(DelaySec) / 60.0 ,2) AS DelayDuration_min,
	NULL AS DelayReasons,
	0 AS DelayCount
FROM ShovelLoad sl
RIGHT JOIN [ABR].[CONOPS_ABR_EOS_SHIFT_INFO_V] s
	ON sl.SHIFTINDEX = s.SHIFTINDEX
GROUP BY
	s.SHIFTFLAG,
	s.siteflag,
	ShovelId,
	Pushback

