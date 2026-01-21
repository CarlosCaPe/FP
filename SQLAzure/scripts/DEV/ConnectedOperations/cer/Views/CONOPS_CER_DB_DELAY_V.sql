CREATE VIEW [cer].[CONOPS_CER_DB_DELAY_V] AS




--SELECT * FROM [cer].[CONOPS_CER_DB_DELAY_V] WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [cer].[CONOPS_CER_DB_DELAY_V]  
AS  
  
	SELECT shiftflag,
		   eqmt,
		   eqmtcurrstatus,
		   eqmttype,
		   sum(duration)/60.00 AS duration,
		   reason,
		   reasonidx
	FROM [cer].[CONOPS_CER_DB_EQMT_STATUS_V] (NOLOCK)
	WHERE siteflag = 'CER'
		 AND [status] = 'Demora'
		 AND reasonidx <> '439'
	GROUP BY shiftflag, eqmt, eqmtcurrstatus, eqmttype, reason, reasonidx
  



