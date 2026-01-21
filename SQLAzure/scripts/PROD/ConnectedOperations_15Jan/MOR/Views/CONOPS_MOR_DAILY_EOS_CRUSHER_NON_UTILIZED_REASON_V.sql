CREATE VIEW [MOR].[CONOPS_MOR_DAILY_EOS_CRUSHER_NON_UTILIZED_REASON_V] AS

--SELECT * FROM [MOR].[CONOPS_MOR_DAILY_EOS_CRUSHER_NON_UTILIZED_REASON_V] WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [MOR].[CONOPS_MOR_DAILY_EOS_CRUSHER_NON_UTILIZED_REASON_V]  
AS  

WITH AllReason AS(
SELECT
	si.SITEFLAG,
	si.shiftflag,
	'Crusher' AS UnitType,
	cs.cause_name AS Reason,
	COALESCE(SUM(cs.act_mins) / 60.0, 0) AS DurationHours,
	ROW_NUMBER() OVER(PARTITION BY si.shiftflag ORDER BY SUM(cs.act_mins) / 60.0 DESC) AS rn
FROM dbo.CRUSHER_STATUS cs WITH(NOLOCK)
INNER JOIN MOR.conops_MOR_EOS_SHIFT_INFO_v si
	ON cs.PRODCTN_DATE = CAST(si.ShiftStartDateTime AS DATE)
	AND cs.SHIFT_INDICATOR = CASE WHEN si.shiftname = 'Day Shift' THEN 'A' 
								WHEN si.shiftname = 'Night Shift' THEN 'C' ELSE si.shiftname END
WHERE cs.site_code = 'MOR'
	AND cs.CAUSE_NAME <> ''
GROUP BY si.shiftflag, si.siteflag, cs.cause_name
)

SELECT
	shiftflag,
	siteflag,
	unittype,
	Reason,
	DurationHours
FROM AllReason
WHERE rn <= 5


