CREATE VIEW [BAG].[CONOPS_BAG_EOS_LINEUP_EQMT_OTHER_V] AS

-- SELECT * FROM [bag].[CONOPS_BAG_EOS_LINEUP_EQMT_OTHER_V] WITH (NOLOCK) WHERE shiftflag = 'CURR'  ORDER BY shiftflag, siteflag, SupportEquipment
CREATE VIEW [bag].[CONOPS_BAG_EOS_LINEUP_EQMT_OTHER_V]
AS

WITH eqtype AS(
SELECT DISTINCT
	EQMT, EQMTTYPE, UNITTYPE
FROM bag.asset_efficiency WITH (NOLOCK)
)

SELECT
	shiftflag,
	siteflag,
	shiftid,
	shiftindex,
	SupportEquipmentId,
	SupportEquipment,
	StatusCode,
	'Ready' AS StatusName,
	StatusStart
FROM(
	SELECT 
		s.shiftflag,
		s.SITEFLAG,
		s.shiftid,
		s.shiftindex,
		h.EQMT AS SupportEquipmentId,
		et.UNITTYPE AS SupportEquipment,
		STATUS AS StatusCode,
		MAX(START_TIME_TS) AS StatusStart
	FROM bag.EQUIPMENT_HOURLY_STATUS h WITH (NOLOCK)
	RIGHT OUTER JOIN bag.CONOPS_BAG_SHIFT_INFO_V s
		ON h.shiftindex = s.shiftindex
	LEFT JOIN eqtype et
		ON h.EQMT = et.EQMT
	WHERE HOS = 0
		AND UNIT NOT IN (1,2,12)
	GROUP BY s.shiftflag, s.SITEFLAG, s.shiftid, s.shiftindex, h.EQMT, et.UNITTYPE, STATUS
) a
WHERE StatusCode = 2


