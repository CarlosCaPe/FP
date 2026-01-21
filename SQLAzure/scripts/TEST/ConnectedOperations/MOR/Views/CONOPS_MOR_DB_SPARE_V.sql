CREATE VIEW [MOR].[CONOPS_MOR_DB_SPARE_V] AS




--SELECT * FROM [mor].[CONOPS_MOR_DB_SPARE_V] WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [mor].[CONOPS_MOR_DB_SPARE_V]  
AS  
  
	SELECT shiftflag,
		   eqmt,
		   eqmtcurrstatus,
		   eqmttype,
		   sum(duration)/60.00 AS duration,
		   reason,
		   reasonidx
	FROM  [mor].[CONOPS_MOR_DB_EQMT_STATUS_V] (NOLOCK)
	WHERE [status] = 'SPARE'
	GROUP BY shiftflag, eqmt, eqmtcurrstatus, eqmttype, reason, reasonidx
  



