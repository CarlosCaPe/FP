CREATE VIEW [CER].[CONOPS_CER_DB_SPARE_V] AS




--SELECT * FROM [cer].[CONOPS_CER_DB_SPARE_V] WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [cer].[CONOPS_CER_DB_SPARE_V]  
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
		 AND [status] = 'Reserva'
	GROUP BY shiftflag, eqmt, eqmtcurrstatus, eqmttype, reason, reasonidx
  



