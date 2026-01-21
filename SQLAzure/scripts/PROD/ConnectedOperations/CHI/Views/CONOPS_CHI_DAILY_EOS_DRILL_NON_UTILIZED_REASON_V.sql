CREATE VIEW [CHI].[CONOPS_CHI_DAILY_EOS_DRILL_NON_UTILIZED_REASON_V] AS

--SELECT * FROM [chi].[CONOPS_CHI_DAILY_EOS_DRILL_NON_UTILIZED_REASON_V] WHERE SHIFTFLAG = 'CURR'
CREATE VIEW [chi].[CONOPS_CHI_DAILY_EOS_DRILL_NON_UTILIZED_REASON_V]
AS

WITH AllReason AS(
SELECT 
	a.SHIFTFLAG
	,a.SiteFlag
	,'Drill' UnitType
	,[stats].Reason
	,SUM([stats].duration / 3600.00) AS DurationHours
	,ROW_NUMBER() OVER(PARTITION BY a.shiftflag ORDER BY SUM([stats].duration) / 3600.0 DESC) AS rn
FROM [CHI].[CONOPS_CHI_EOS_SHIFT_INFO_V] A (NOLOCK) 
LEFT JOIN [CHI].[CONOPS_CHI_DAILY_DB_EQMT_STATUS_V] [stats] (NOLOCK)
	ON a.SHIFTFLAG = [stats].SHIFTFLAG
WHERE [stats].status IN ('Delay', 'Spare')
GROUP BY a.SHIFTFLAG, a.SiteFlag, [stats].Reason	
)

SELECT
	shiftflag,
	siteflag,
	unittype,
	Reason,
	DurationHours
FROM AllReason
WHERE rn <= 5

