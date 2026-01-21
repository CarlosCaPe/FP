CREATE VIEW [TYR].[CONOPS_TYR_SP_SPARE_V] AS



  
  
  
--select * from [dbo].[CONOPS_LH_SP_SPARE_V]  
  
CREATE VIEW [TYR].[CONOPS_TYR_SP_SPARE_V]  
AS  
  
SELECT  
shiftflag,  
siteflag,  
shiftid,  
eqmt,  
eqmttype,  
sum(duration)/60.00 as duration,  
reasons,  
reasonidx,  
eqmtcurrstatus  
FROM [tyr].[CONOPS_TYR_SP_EQMT_STATUS_V] (NOLOCK)  
WHERE siteflag = 'TYR'  
AND [status] = 'SPARE'  
GROUP BY shiftflag,siteflag,shiftid,reasons,reasonidx,eqmt,eqmttype,eqmtcurrstatus  
  
  


