CREATE VIEW [MOR].[CONOPS_MOR_TP_SPARE_V] AS



--select * from [dbo].[CONOPS_LH_TP_SPARE_V]

CREATE VIEW [mor].[CONOPS_MOR_TP_SPARE_V]
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
FROM [mor].[CONOPS_MOR_TP_EQMT_STATUS_V] (NOLOCK)
WHERE siteflag = 'MOR'
AND [status] = 'SPARE'
GROUP BY shiftflag,siteflag,shiftid,reasons,reasonidx,eqmt,eqmttype,eqmtcurrstatus



