CREATE VIEW [ABR].[CONOPS_ABR_TP_DELAY_V] AS






--select * from [abr].[CONOPS_ABR_TP_DELAY_V] where shiftflag = 'prev'

CREATE VIEW [ABR].[CONOPS_ABR_TP_DELAY_V]
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
FROM [abr].[CONOPS_ABR_TP_EQMT_STATUS_V] (NOLOCK)
WHERE [status] = 'Demora'
AND reasonidx <> '439'
GROUP BY shiftflag,siteflag,shiftid,reasons,reasonidx,eqmt,eqmttype,eqmtcurrstatus



