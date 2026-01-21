CREATE VIEW [CLI].[CONOPS_CLI_EOS_TRUCK_NON_UTILIZED_REASON_V] AS
 
--SELECT * FROM [CLI].[CONOPS_CLI_EOS_TRUCK_NON_UTILIZED_REASON_V] WHERE SHIFTFLAG = 'CURR'
CREATE VIEW [CLI].[CONOPS_CLI_EOS_TRUCK_NON_UTILIZED_REASON_V]
AS

WITH AllReason AS(
SELECT
	s.shiftflag,
	s.siteflag,
	'Truck' AS unittype,
	e.reasons AS Reason,
	COALESCE(SUM(e.DURATION) / 3600.0, 0) AS DurationHours,
	ROW_NUMBER() OVER(PARTITION BY s.shiftflag ORDER BY SUM(e.DURATION) / 3600.0 DESC) AS rn
FROM CLI.ASSET_EFFICIENCY e WITH (NOLOCK)
INNER JOIN CLI.CONOPS_CLI_SHIFT_INFO_V s WITH (NOLOCK)
	ON e.SHIFTID = s.shiftid
WHERE e.UNITTYPE = 'Truck'
	AND (e.categoryidx = 3 OR e.statusidx IN (3, 4))
GROUP BY s.shiftflag, s.siteflag, e.reasons
)

SELECT
	shiftflag,
	siteflag,
	unittype,
	Reason,
	DurationHours
FROM AllReason
WHERE rn <= 5

