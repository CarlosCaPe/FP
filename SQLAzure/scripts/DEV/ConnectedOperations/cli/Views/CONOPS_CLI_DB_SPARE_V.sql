CREATE VIEW [cli].[CONOPS_CLI_DB_SPARE_V] AS




--SELECT * FROM [cli].[CONOPS_CLI_DB_SPARE_V] WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [cli].[CONOPS_CLI_DB_SPARE_V]  
AS  
  
	SELECT shiftflag,
		   eqmt,
		   eqmtcurrstatus,
		   eqmttype,
		   sum(duration)/60.00 AS duration,
		   reason,
		   reasonidx
	FROM  [cli].[CONOPS_CLI_DB_EQMT_STATUS_V] (NOLOCK)
	WHERE [status] = 'SPARE'
	GROUP BY shiftflag, eqmt, eqmtcurrstatus, eqmttype, reason, reasonidx
  



