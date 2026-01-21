CREATE VIEW [bag].[CONOPS_BAG_EOS_KPI_SUMMARY_HOURLY_AVG_DURATION_V] AS

-- SELECT * FROM [bag].[CONOPS_BAG_EOS_KPI_SUMMARY_HOURLY_AVG_DURATION_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [bag].[CONOPS_BAG_EOS_KPI_SUMMARY_HOURLY_AVG_DURATION_V]  
AS  
  
SELECT
	e.shiftindex,
	s.shiftflag,
	s.siteflag,
	e.HOS,
	AVG(e.DURATION) AS AvgDuration,
	DATEADD(HOUR, e.HOS, s.shiftstartdatetime) AS Hr
FROM [bag].FLEET_EQUIPMENT_HOURLY_STATUS_V e
LEFT JOIN BAG.CONOPS_BAG_SHIFT_INFO_V s
	ON e.SHIFTID = s.shiftid
WHERE e.UNIT = 1
	AND e.Status = 4
	AND e.Reason = 439
GROUP BY e.shiftindex, s.shiftflag, s.siteflag, e.HOS, s.shiftstartdatetime


