CREATE VIEW [dbo].[CONOPS_LH_SP_SPARE_V] AS



--select * from [dbo].[CONOPS_LH_SP_SPARE_V]

CREATE VIEW [dbo].[CONOPS_LH_SP_SPARE_V]
AS

SELECT
shiftflag,
siteflag,
shiftid,
sum(duration)/2400 as duration,
reasons,
reasonidx
FROM [mor].[CONOPS_MOR_SP_EQMT_STATUS_V] (NOLOCK)
WHERE siteflag = 'MOR'
AND [status] = 'SPARE'
GROUP BY shiftflag,siteflag,shiftid,reasons,reasonidx

UNION ALL


SELECT
shiftflag,
siteflag,
shiftid,
sum(duration)/2400 as duration,
reasons,
reasonidx
FROM [bag].[CONOPS_BAG_SP_EQMT_STATUS_V] (NOLOCK)
WHERE siteflag = 'BAG'
AND [status] = 'SPARE'
GROUP BY shiftflag,siteflag,shiftid,reasons,reasonidx

UNION ALL


SELECT
shiftflag,
siteflag,
shiftid,
sum(duration)/2400 as duration,
reasons,
reasonidx
FROM [saf].[CONOPS_SAF_SP_EQMT_STATUS_V] (NOLOCK)
WHERE siteflag = 'SAF'
AND [status] = 'SPARE'
GROUP BY shiftflag,siteflag,shiftid,reasons,reasonidx


UNION ALL


SELECT
shiftflag,
siteflag,
shiftid,
sum(duration)/2400 as duration,
reasons,
reasonidx
FROM [sie].[CONOPS_SIE_SP_EQMT_STATUS_V] (NOLOCK)
WHERE siteflag = 'SIE'
AND [status] = 'SPARE'
GROUP BY shiftflag,siteflag,shiftid,reasons,reasonidx


UNION ALL


SELECT
shiftflag,
siteflag,
shiftid,
sum(duration)/2400 as duration,
reasons,
reasonidx
FROM [cli].[CONOPS_CLI_SP_EQMT_STATUS_V] (NOLOCK)
WHERE siteflag = 'CMX'
AND [status] = 'SPARE'
GROUP BY shiftflag,siteflag,shiftid,reasons,reasonidx

UNION ALL


SELECT
shiftflag,
siteflag,
shiftid,
sum(duration)/2400 as duration,
reasons,
reasonidx
FROM [chi].[CONOPS_CHI_SP_EQMT_STATUS_V] (NOLOCK)
WHERE siteflag = 'CHI'
AND UPPER([status]) = 'SPARE'
GROUP BY shiftflag,siteflag,shiftid,reasons,reasonidx


UNION ALL

SELECT
shiftflag,
siteflag,
shiftid,
sum(duration)/2400 as duration,
reasons,
reasonidx
FROM [cer].[CONOPS_CER_SP_EQMT_STATUS_V] (NOLOCK)
WHERE siteflag = 'CER'
AND UPPER([status]) = 'Reserva'
GROUP BY shiftflag,siteflag,shiftid,reasons,reasonidx

