CREATE VIEW [ABR].[CONOPS_ABR_DB_DELAY_V] AS




--SELECT * FROM [abr].[CONOPS_ABR_DB_DELAY_V] WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [ABR].[CONOPS_ABR_DB_DELAY_V]  
AS  
  
	SELECT shiftflag,
		   eqmt,
		   eqmtcurrstatus,
		   eqmttype,
		   sum(duration)/60.00 AS duration,
		   reason,
		   reasonidx
	FROM  [abr].[CONOPS_ABR_DB_EQMT_STATUS_V] (NOLOCK)
	WHERE [status] = 'Demora'
		  AND reasonidx <> '439'
	GROUP BY shiftflag, eqmt, eqmtcurrstatus, eqmttype, reason, reasonidx
  



