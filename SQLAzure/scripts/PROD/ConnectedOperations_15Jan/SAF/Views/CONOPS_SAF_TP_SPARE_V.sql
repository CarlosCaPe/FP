CREATE VIEW [SAF].[CONOPS_SAF_TP_SPARE_V] AS



--select * from [dbo].[CONOPS_LH_SP_DELAY_V] where shiftflag = 'prev'
CREATE VIEW [saf].[CONOPS_SAF_TP_SPARE_V]
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
FROM [saf].[CONOPS_SAF_TP_EQMT_STATUS_V] (NOLOCK)
WHERE siteflag = 'SAF'
AND [status] = 'SPARE'
GROUP BY shiftflag,siteflag,shiftid,reasons,reasonidx,eqmt,eqmttype,eqmtcurrstatus


