CREATE VIEW [cer].[CONOPS_CER_SP_SPARE_V] AS



--select * from [dbo].[CONOPS_LH_SP_DELAY_V] where shiftflag = 'prev'
CREATE VIEW [cer].[CONOPS_CER_SP_SPARE_V]
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
FROM [cer].[CONOPS_CER_SP_EQMT_STATUS_V] (NOLOCK)
WHERE siteflag = 'CER'
AND UPPER([status]) = 'Reserva'
GROUP BY shiftflag,siteflag,shiftid,reasons,reasonidx,eqmt,eqmttype,eqmtcurrstatus


