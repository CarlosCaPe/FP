CREATE VIEW [SIE].[CONOPS_SIE_DB_DELAY_V] AS




--SELECT * FROM [sie].[CONOPS_SIE_DB_DELAY_V] WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [sie].[CONOPS_SIE_DB_DELAY_V]  
AS  
  
	SELECT shiftflag,
		   eqmt,
		   eqmtcurrstatus,
		   eqmttype,
		   sum(duration)/60.00 AS duration,
		   reason,
		   reasonidx
	FROM  [sie].[CONOPS_SIE_DB_EQMT_STATUS_V] (NOLOCK)
	WHERE [status] = 'DELAY'
		  AND reasonidx <> '439'
	GROUP BY shiftflag, eqmt, eqmtcurrstatus, eqmttype, reason, reasonidx
  



