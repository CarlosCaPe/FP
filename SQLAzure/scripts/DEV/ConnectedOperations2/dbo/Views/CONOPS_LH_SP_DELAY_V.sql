CREATE VIEW [dbo].[CONOPS_LH_SP_DELAY_V] AS


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

