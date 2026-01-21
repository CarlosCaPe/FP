CREATE VIEW [BAG].[CONOPS_BAG_EOS_LINEUP_TRUCK_V] AS

-- SELECT * FROM [bag].[CONOPS_BAG_EOS_LINEUP_TRUCK_V]  WITH (NOLOCK) WHERE [shiftflag] = 'CURR'
CREATE VIEW [bag].[CONOPS_BAG_EOS_LINEUP_TRUCK_V] 
AS

SELECT
	shiftflag,
	siteflag,
	shiftid,
	TruckId,
	StatusCode,
	'Ready' AS StatusName,
	StatusStart
FROM(
	SELECT 
		s.shiftflag,
		s.SITEFLAG,
		s.shiftid,
		EQMT AS TruckID,
		STATUS AS StatusCode,
		MAX(START_TIME_TS) AS StatusStart
	FROM bag.EQUIPMENT_HOURLY_STATUS h WITH (NOLOCK)
	RIGHT OUTER JOIN bag.CONOPS_BAG_SHIFT_INFO_V s
		ON h.shiftindex = s.shiftindex
	WHERE HOS = 0
		AND UNIT = 1
	GROUP BY s.shiftflag, s.SITEFLAG, s.shiftid, EQMT, STATUS
) a
WHERE StatusCode = 2

