CREATE VIEW [ABR].[CONOPS_ABR_DB_SPARE_V] AS




--SELECT * FROM [abr].[CONOPS_ABR_DB_SPARE_V] WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [ABR].[CONOPS_ABR_DB_SPARE_V]  
AS  
  
	SELECT shiftflag,
		   eqmt,
		   eqmtcurrstatus,
		   eqmttype,
		   sum(duration)/60.00 AS duration,
		   reason,
		   reasonidx
	FROM  [abr].[CONOPS_ABR_DB_EQMT_STATUS_V] (NOLOCK)
	WHERE [status] = 'Disponible'
	GROUP BY shiftflag, eqmt, eqmtcurrstatus, eqmttype, reason, reasonidx
  



