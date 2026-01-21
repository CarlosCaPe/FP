CREATE VIEW [MOR].[CONOPS_MOR_DAILY_EOS_SHOVEL_NON_UTILIZED_REASON_V] AS

--SELECT * FROM [MOR].[CONOPS_MOR_DAILY_EOS_SHOVEL_NON_UTILIZED_REASON_V] WHERE SHIFTFLAG = 'CURR'
CREATE VIEW [MOR].[CONOPS_MOR_DAILY_EOS_SHOVEL_NON_UTILIZED_REASON_V]
AS

WITH AllReason AS(
SELECT
	s.shiftflag,
	s.siteflag,
	'Shovel' AS unittype,
	e.reasons AS Reason,
	COALESCE(SUM(e.DURATION) / 3600.0, 0) AS DurationHours,
	ROW_NUMBER() OVER(PARTITION BY s.shiftflag ORDER BY SUM(e.DURATION) / 3600.0 DESC) AS rn
FROM MOR.ASSET_EFFICIENCY e WITH (NOLOCK)
INNER JOIN MOR.CONOPS_MOR_EOS_SHIFT_INFO_V s WITH (NOLOCK)
	ON e.SHIFTID = s.shiftid
WHERE e.UNITTYPE = 'Shovel'
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

