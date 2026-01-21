CREATE VIEW [bag].[CONOPS_BAG_TP_DELAY_V] AS



--select * from [bag].[CONOPS_BAG_TP_DELAY_V] where shiftflag = 'prev'

CREATE VIEW [bag].[CONOPS_BAG_TP_DELAY_V]
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
FROM [bag].[CONOPS_BAG_TP_EQMT_STATUS_V] (NOLOCK)
WHERE siteflag = 'BAG'
AND [status] = 'DELAY'
AND reasonidx <> '439'
GROUP BY shiftflag,siteflag,shiftid,reasons,reasonidx,eqmt,eqmttype,eqmtcurrstatus



