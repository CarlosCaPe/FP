CREATE VIEW [CHI].[CONOPS_CHI_SP_SPARE_V] AS



--select * from [dbo].[CONOPS_LH_SP_DELAY_V] where shiftflag = 'prev'
CREATE VIEW [chi].[CONOPS_CHI_SP_SPARE_V]
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
FROM [chi].[CONOPS_CHI_SP_EQMT_STATUS_V] (NOLOCK)
WHERE siteflag = 'CHI'
AND UPPER([status]) = 'SPARE'
GROUP BY shiftflag,siteflag,shiftid,reasons,reasonidx,eqmt,eqmttype,eqmtcurrstatus



