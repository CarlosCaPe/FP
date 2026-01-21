CREATE VIEW [cli].[CONOPS_CLI_TP_DELAY_V] AS



--select * from [dbo].[CONOPS_LH_SP_DELAY_V] where shiftflag = 'prev'
CREATE VIEW [cli].[CONOPS_CLI_TP_DELAY_V]
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
FROM [cli].[CONOPS_CLI_TP_EQMT_STATUS_V] (NOLOCK)
WHERE siteflag = 'CMX'
AND [status] = 'DELAY'
AND reasonidx <> '439'
GROUP BY shiftflag,siteflag,shiftid,reasons,reasonidx,eqmt,eqmttype,eqmtcurrstatus


