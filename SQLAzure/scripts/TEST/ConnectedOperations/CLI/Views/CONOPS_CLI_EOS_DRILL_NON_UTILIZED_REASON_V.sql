CREATE VIEW [CLI].[CONOPS_CLI_EOS_DRILL_NON_UTILIZED_REASON_V] AS

--SELECT * FROM [cli].[CONOPS_CLI_EOS_DRILL_NON_UTILIZED_REASON_V] WHERE SHIFTFLAG = 'CURR'
CREATE VIEW [cli].[CONOPS_CLI_EOS_DRILL_NON_UTILIZED_REASON_V]
AS

WITH AllReason AS(
SELECT 
	a.SHIFTFLAG
	,a.SiteFlag
	,'Drill' UnitType
	,[stats].Reason
	,SUM([stats].duration / 3600.00) AS DurationHours
	,ROW_NUMBER() OVER(PARTITION BY a.shiftflag ORDER BY SUM([stats].duration) / 3600.0 DESC) AS rn
FROM [CLI].[CONOPS_CLI_SHIFT_INFO_V] A (NOLOCK) 
LEFT JOIN [CLI].[CONOPS_CLI_DB_EQMT_STATUS_V] [stats] (NOLOCK)
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

