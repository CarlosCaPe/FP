CREATE VIEW [SAF].[CONOPS_SAF_DB_DELAY_V] AS




--SELECT * FROM [saf].[CONOPS_SAF_DB_DELAY_V] WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [saf].[CONOPS_SAF_DB_DELAY_V]  
AS  
  
	SELECT shiftflag,
		   eqmt,
		   eqmtcurrstatus,
		   eqmttype,
		   sum(duration)/60.00 AS duration,
		   reason,
		   reasonidx
	FROM  [saf].[CONOPS_SAF_DB_EQMT_STATUS_V] (NOLOCK)
	WHERE [status] = 'DELAY'
		  AND reasonidx <> '439'
	GROUP BY shiftflag, eqmt, eqmtcurrstatus, eqmttype, reason, reasonidx
  



