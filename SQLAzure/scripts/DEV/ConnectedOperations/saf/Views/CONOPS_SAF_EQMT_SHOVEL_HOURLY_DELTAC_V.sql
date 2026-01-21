CREATE VIEW [saf].[CONOPS_SAF_EQMT_SHOVEL_HOURLY_DELTAC_V] AS



--select * from [SAF].[CONOPS_SAF_EQMT_SHOVEL_HOURLY_DELTAC_V] where shiftflag = 'prev' and equipment = 's08'
CREATE VIEW [saf].[CONOPS_SAF_EQMT_SHOVEL_HOURLY_DELTAC_V]
AS

WITH CTE AS (
SELECT 
shiftindex,
excav AS Equipment,
deltac_ts,
avg(delta_c) AS deltac,
AVG(SHOVEL_IDLEDELTA) AS idletime,
AVG(SPOTDELTA) AS spottime,
AVG(LOADDELTA) AS loadtime,
AVG(hangtime)/60.0 AS hangtime
FROM dbo.delta_c WITH (NOLOCK)
WHERE site_code = 'SAF'
GROUP BY site_code,shiftindex,excav,deltac_ts)

SELECT 
shiftflag,
siteflag,
Equipment,
deltac_ts,
ROUND(deltac,2) deltac,
ROUND(idletime,2) idletime,
ROUND(spottime,2) spottime,
ROUND(loadtime,2) loadtime,
ROUND(hangtime,2) hangtime
FROM SAF.CONOPS_SAF_SHIFT_INFO_V a
LEFT JOIN CTE b on a.shiftindex = b.shiftindex 


