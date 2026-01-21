CREATE VIEW [MOR].[CONOPS_MOR_DB_DELAY_V] AS



--SELECT * FROM [mor].[CONOPS_MOR_DB_DELAY_V] WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [mor].[CONOPS_MOR_DB_DELAY_V]  
AS  
  
	SELECT shiftflag,
		   eqmt,
		   eqmtcurrstatus,
		   eqmttype,
		   sum(duration)/2400.00 AS duration,
		   reason,
		   reasonidx
	FROM  [mor].[CONOPS_MOR_DB_EQMT_STATUS_V] (NOLOCK)
	WHERE [status] = 'DELAY'
		  AND reasonidx <> '439'
	GROUP BY shiftflag, eqmt, eqmtcurrstatus, eqmttype, reason, reasonidx
  


