CREATE VIEW [CHI].[CONOPS_CHI_TP_DELAY_V] AS



--select * from [dbo].[CONOPS_LH_SP_DELAY_V] where shiftflag = 'prev'
CREATE VIEW [chi].[CONOPS_CHI_TP_DELAY_V]
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
FROM [chi].[CONOPS_CHI_TP_EQMT_STATUS_V] (NOLOCK)
WHERE siteflag = 'CHI'
AND [status] = 'DELAY'
AND reasonidx <> '439'
GROUP BY shiftflag,siteflag,shiftid,reasons,reasonidx,eqmt,eqmttype,eqmtcurrstatus


