CREATE VIEW [dbo].[ZZZ_CONOPS_DB_SPARE_V] AS




--select * from [dbo].[CONOPS_DB_SPARE_V]

CREATE VIEW [dbo].[CONOPS_DB_SPARE_V]
AS

SELECT shiftflag,
       siteflag,
       shiftid,
       sum(duration)/2400.00 AS duration,
       reason,
       reasonidx
FROM [mor].[CONOPS_MOR_DB_EQMT_STATUS_V] (NOLOCK)
WHERE siteflag = 'MOR'
     AND [status] = 'SPARE'
GROUP BY shiftflag, siteflag, shiftid, reason, reasonidx

UNION ALL

SELECT shiftflag,
       siteflag,
       shiftid,
       sum(duration)/2400.00 AS duration,
       reason,
       reasonidx
FROM [bag].[CONOPS_BAG_DB_EQMT_STATUS_V] (NOLOCK)
WHERE siteflag = 'BAG'
     AND [status] = 'SPARE'
GROUP BY shiftflag, siteflag, shiftid, reason, reasonidx

UNION ALL

SELECT shiftflag,
       siteflag,
       shiftid,
       sum(duration)/2400.00 AS duration,
       reason,
       reasonidx
FROM [saf].[CONOPS_SAF_DB_EQMT_STATUS_V] (NOLOCK)
WHERE siteflag = 'SAF'
     AND [status] = 'SPARE'
GROUP BY shiftflag, siteflag, shiftid, reason, reasonidx

UNION ALL

SELECT shiftflag,
       siteflag,
       shiftid,
       sum(duration)/2400.00 AS duration,
       reason,
       reasonidx
FROM [sie].[CONOPS_SIE_DB_EQMT_STATUS_V] (NOLOCK)
WHERE siteflag = 'SIE'
     AND [status] = 'SPARE'
GROUP BY shiftflag, siteflag, shiftid, reason, reasonidx

UNION ALL

SELECT shiftflag,
       siteflag,
       shiftid,
       sum(duration)/2400.00 AS duration,
       reason,
       reasonidx
FROM [cli].[CONOPS_CLI_DB_EQMT_STATUS_V] (NOLOCK)
WHERE siteflag = 'CMX'
     AND [status] = 'SPARE'
GROUP BY shiftflag, siteflag, shiftid, reason, reasonidx

UNION ALL

SELECT shiftflag,
       siteflag,
       shiftid,
       sum(duration)/2400.00 AS duration,
       reason,
       reasonidx
FROM [chi].[CONOPS_CHI_DB_EQMT_STATUS_V] (NOLOCK)
WHERE siteflag = 'CHI'
     AND [status] = 'SPARE'
GROUP BY shiftflag, siteflag, shiftid, reason, reasonidx

UNION ALL

SELECT shiftflag,
       siteflag,
       shiftid,
       sum(duration)/2400.00 AS duration,
       reason,
       reasonidx
FROM [cer].[CONOPS_CER_DB_EQMT_STATUS_V] (NOLOCK)
WHERE siteflag = 'CER'
     AND [status] = 'Reserva'
GROUP BY shiftflag, siteflag, shiftid, reason, reasonidx

