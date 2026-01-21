CREATE VIEW [CLI].[CONOPS_CLI_SP_SPARE_V] AS



--select * from [dbo].[CONOPS_LH_SP_DELAY_V] where shiftflag = 'prev'
CREATE VIEW [cli].[CONOPS_CLI_SP_SPARE_V]
AS

SELECT
shiftflag,
siteflag,
shiftid,
eqmt,
eqmttype,
sum(duration)/3600 as duration,
reasons,
reasonidx,
eqmtcurrstatus
FROM [cli].[CONOPS_CLI_SP_EQMT_STATUS_V] (NOLOCK)
WHERE siteflag = 'CMX'
AND [status] = 'SPARE'
GROUP BY shiftflag,siteflag,shiftid,reasons,reasonidx,eqmt,eqmttype,eqmtcurrstatus


