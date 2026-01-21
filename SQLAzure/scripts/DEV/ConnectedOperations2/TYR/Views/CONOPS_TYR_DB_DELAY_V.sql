CREATE VIEW [TYR].[CONOPS_TYR_DB_DELAY_V] AS


--SELECT * FROM [tyr].[CONOPS_TYR_DB_DELAY_V] WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [TYR].[CONOPS_TYR_DB_DELAY_V]  
AS  
  
	SELECT shiftflag,
		   eqmt,
		   eqmtcurrstatus,
		   eqmttype,
		   sum(duration)/2400.00 AS duration,
		   reason,
		   reasonidx
	FROM  [tyr].[CONOPS_TYR_DB_EQMT_STATUS_V] (NOLOCK)
	WHERE [status] = 'DELAY'
		  AND reasonidx <> '439'
	GROUP BY shiftflag, eqmt, eqmtcurrstatus, eqmttype, reason, reasonidx
  


