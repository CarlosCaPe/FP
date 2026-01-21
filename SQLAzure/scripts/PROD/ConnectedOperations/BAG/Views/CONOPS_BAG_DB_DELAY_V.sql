CREATE VIEW [BAG].[CONOPS_BAG_DB_DELAY_V] AS





--SELECT * FROM [bag].[CONOPS_BAG_DB_DELAY_V] WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [bag].[CONOPS_BAG_DB_DELAY_V]  
AS  
  
	SELECT shiftflag,
		   eqmt,
		   eqmtcurrstatus,
		   eqmttype,
		   sum(duration)/60.00 AS duration,
		   reason,
		   reasonidx
	FROM [bag].[CONOPS_BAG_DB_EQMT_STATUS_V] (NOLOCK)
	WHERE siteflag = 'BAG'
		 AND [status] = 'DELAY'
		 AND reasonidx <> '439'
	GROUP BY shiftflag, eqmt, eqmtcurrstatus, eqmttype, reason, reasonidx
  



