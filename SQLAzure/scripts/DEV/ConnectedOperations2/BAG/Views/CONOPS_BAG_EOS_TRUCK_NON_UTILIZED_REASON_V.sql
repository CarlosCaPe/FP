CREATE VIEW [BAG].[CONOPS_BAG_EOS_TRUCK_NON_UTILIZED_REASON_V] AS






--SELECT * FROM [BAG].[CONOPS_BAG_EOS_TRUCK_NON_UTILIZED_REASON_V] WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [bag].[CONOPS_BAG_EOS_TRUCK_NON_UTILIZED_REASON_V]  
AS  
  
SELECT
	--s.shiftindex,
	s.shiftflag,
	s.siteflag,
	'Truck' AS unittype,
	e.reasons AS Reason,
	COALESCE(SUM(e.DURATION) / 3600.0, 0) AS DurationHours
FROM [bag].ASSET_EFFICIENCY e WITH (NOLOCK)
LEFT JOIN BAG.CONOPS_BAG_SHIFT_INFO_V s WITH (NOLOCK)
	ON e.SHIFTID = s.shiftid
WHERE e.UNITTYPE = 'Truck'
	AND (e.categoryidx = 3 OR e.statusidx IN (3, 4))
GROUP BY s.shiftindex, s.shiftflag, s.siteflag, e.reasons




