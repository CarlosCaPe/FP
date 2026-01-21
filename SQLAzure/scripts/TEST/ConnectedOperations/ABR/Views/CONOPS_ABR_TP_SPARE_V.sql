CREATE VIEW [ABR].[CONOPS_ABR_TP_SPARE_V] AS






--select * from [dbo].[CONOPS_LH_TP_SPARE_V]

CREATE VIEW [ABR].[CONOPS_ABR_TP_SPARE_V]
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
WHERE [status] = 'Disponible'
GROUP BY shiftflag,siteflag,shiftid,reasons,reasonidx,eqmt,eqmttype,eqmtcurrstatus




