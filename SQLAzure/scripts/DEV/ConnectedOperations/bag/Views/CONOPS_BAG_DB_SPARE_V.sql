CREATE VIEW [bag].[CONOPS_BAG_DB_SPARE_V] AS





--SELECT * FROM [bag].[CONOPS_BAG_DB_SPARE_V] WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [bag].[CONOPS_BAG_DB_SPARE_V]  
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
		 AND [status] = 'SPARE'
	GROUP BY shiftflag, eqmt, eqmtcurrstatus, eqmttype, reason, reasonidx
  



