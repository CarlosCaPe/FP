CREATE VIEW [CER].[CONOPS_CER_EOS_CRUSHER_NON_UTILIZED_REASON_V] AS

--SELECT * FROM [CER].[CONOPS_CER_EOS_CRUSHER_NON_UTILIZED_REASON_V] WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [cer].[CONOPS_CER_EOS_CRUSHER_NON_UTILIZED_REASON_V]  
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
INNER JOIN CER.conops_CER_shift_info_v si
	ON cs.PRODCTN_DATE = si.SHIFTSTARTDATE
	AND cs.SHIFT_INDICATOR = REPLACE(si.shiftname, ' Shift', '')
WHERE cs.site_code = 'CER'
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

