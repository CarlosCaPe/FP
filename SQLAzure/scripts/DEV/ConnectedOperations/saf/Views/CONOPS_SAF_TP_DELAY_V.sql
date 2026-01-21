CREATE VIEW [saf].[CONOPS_SAF_TP_DELAY_V] AS



--select * from [saf].[CONOPS_SAF_TP_DELAY_V] where shiftflag = 'prev'

CREATE VIEW [saf].[CONOPS_SAF_TP_DELAY_V]
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
AND [status] = 'DELAY'
AND reasonidx <> '439'
GROUP BY shiftflag,siteflag,shiftid,reasons,reasonidx,eqmt,eqmttype,eqmtcurrstatus


