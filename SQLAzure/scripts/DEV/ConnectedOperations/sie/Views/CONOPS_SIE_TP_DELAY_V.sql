CREATE VIEW [sie].[CONOPS_SIE_TP_DELAY_V] AS



--select * from [sie].[CONOPS_SIE_TP_DELAY_V] where shiftflag = 'prev'

CREATE VIEW [sie].[CONOPS_SIE_TP_DELAY_V]
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
FROM [sie].[CONOPS_SIE_TP_EQMT_STATUS_V] (NOLOCK)
WHERE siteflag = 'SIE'
AND [status] = 'DELAY'
AND reasonidx <> '439'
GROUP BY shiftflag,siteflag,shiftid,reasons,reasonidx,eqmt,eqmttype,eqmtcurrstatus


