CREATE VIEW [dbo].[CONOPS_LH_SP_DELAY_V] AS





--select * from [dbo].[CONOPS_LH_SP_DELAY_V] where shiftflag = 'prev'
CREATE VIEW [dbo].[CONOPS_LH_SP_DELAY_V]
AS

SELECT
shiftflag,
siteflag,
shiftid,
sum(duration)/2400.00 as duration,
reasons,
reasonidx
FROM [mor].[CONOPS_MOR_SP_EQMT_STATUS_V] (NOLOCK)
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
FROM [bag].[CONOPS_BAG_SP_EQMT_STATUS_V] (NOLOCK)
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
FROM [saf].[CONOPS_SAF_SP_EQMT_STATUS_V] (NOLOCK)
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
FROM [sie].[CONOPS_SIE_SP_EQMT_STATUS_V] (NOLOCK)
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
FROM [cli].[CONOPS_CLI_SP_EQMT_STATUS_V] (NOLOCK)
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
FROM [chi].[CONOPS_CHI_SP_EQMT_STATUS_V] (NOLOCK)
WHERE siteflag = 'CHI'
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
FROM [cer].[CONOPS_CER_SP_EQMT_STATUS_V] (NOLOCK)
WHERE siteflag = 'CER'
AND [status] = 'Demora'
AND reasonidx <> '439'
GROUP BY shiftflag,siteflag,shiftid,reasons,reasonidx


