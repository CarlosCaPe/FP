CREATE VIEW [bag].[CONOPS_BAG_EOS_SHOVEL_NON_UTILIZED_REASON_V] AS





--SELECT * FROM [BAG].[CONOPS_BAG_EOS_SHOVEL_NON_UTILIZED_REASON_V] WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [bag].[CONOPS_BAG_EOS_SHOVEL_NON_UTILIZED_REASON_V]  
AS  
  
SELECT
	--s.shiftindex,
	s.shiftflag,
	s.siteflag,
	'Shovel' AS unittype,
	e.reasons AS Reason,
	COALESCE(SUM(e.DURATION) / 3600.0, 0) AS DurationHours
FROM [bag].FLEET_ASSET_EFFICIENCY_V e
LEFT JOIN BAG.CONOPS_BAG_SHIFT_INFO_V s
	ON e.SHIFTID = s.shiftid
WHERE e.UNITTYPE = 'Shovel'
	AND (e.categoryidx = 3 OR e.statusidx IN (3, 4))
GROUP BY s.shiftindex, s.shiftflag, s.siteflag, e.reasons


