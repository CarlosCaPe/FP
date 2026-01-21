CREATE VIEW [dbo].[CONOPS_LH_TP_DELAY_V] AS







--select * from [dbo].[CONOPS_LH_TP_DELAY_V] where shiftflag = 'prev'

CREATE VIEW [dbo].[CONOPS_LH_TP_DELAY_V]
AS

SELECT
shiftflag,
siteflag,
shiftid,
sum(duration)/2400.00 as duration,
reasons,
reasonidx
FROM [mor].[CONOPS_MOR_TP_EQMT_STATUS_V] (NOLOCK)
WHERE siteflag = 'MOR'
AND [status] = 'DELAY'
AND reasonidx <> '439'
GROUP BY shiftflag,siteflag,shiftid,reasons,reasonidx

UNION ALL


SELECT
shiftflag,
siteflag,
shiftid,
sum(duration)/2400.00 as duration,
reasons,
reasonidx
FROM [bag].[CONOPS_BAG_TP_EQMT_STATUS_V] (NOLOCK)
WHERE siteflag = 'BAG'
AND [status] = 'DELAY'
AND reasonidx <> '439'
GROUP BY shiftflag,siteflag,shiftid,reasons,reasonidx


UNION ALL



SELECT
shiftflag,
siteflag,
shiftid,
sum(duration)/2400.00 as duration,
reasons,
reasonidx
FROM [sie].[CONOPS_SIE_TP_EQMT_STATUS_V] (NOLOCK)
WHERE siteflag = 'SIE'
AND [status] = 'DELAY'
AND reasonidx <> '439'
GROUP BY shiftflag,siteflag,shiftid,reasons,reasonidx


UNION ALL


SELECT
shiftflag,
siteflag,
shiftid,
sum(duration)/2400.00 as duration,
reasons,
reasonidx
FROM [saf].[CONOPS_SAF_TP_EQMT_STATUS_V] (NOLOCK)
WHERE siteflag = 'SAF'
AND [status] = 'DELAY'
AND reasonidx <> '439'
GROUP BY shiftflag,siteflag,shiftid,reasons,reasonidx


UNION ALL


SELECT
shiftflag,
siteflag,
shiftid,
sum(duration)/2400.00 as duration,
reasons,
reasonidx
FROM [cli].[CONOPS_CLI_TP_EQMT_STATUS_V] (NOLOCK)
WHERE siteflag = 'CMX'
AND [status] = 'DELAY'
AND reasonidx <> '439'
GROUP BY shiftflag,siteflag,shiftid,reasons,reasonidx



UNION ALL

SELECT
shiftflag,
siteflag,
shiftid,
sum(duration)/2400.00 as duration,
reasons,
reasonidx
FROM [cer].[CONOPS_CER_TP_EQMT_STATUS_V] (NOLOCK)
WHERE siteflag = 'CER'
AND [status] = 'Demora'
AND reasonidx <> '439'
GROUP BY shiftflag,siteflag,shiftid,reasons,reasonidx

UNION ALL

SELECT
shiftflag,
siteflag,
shiftid,
sum(duration)/2400.00 as duration,
reasons,
reasonidx
FROM [chi].[CONOPS_CHI_TP_EQMT_STATUS_V] (NOLOCK)
WHERE siteflag = 'CHI'
AND [status] = 'DELAY'
AND reasonidx <> '439'
GROUP BY shiftflag,siteflag,shiftid,reasons,reasonidx

