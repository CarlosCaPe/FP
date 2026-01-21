CREATE VIEW [dbo].[CONOPS_EQMT_SHOVEL_HOURLY_SPOTLOADIDLETIME_V] AS





--select * from [dbo].[CONOPS_EQMT_SHOVEL_HOURLY_SPOTLOADIDLETIME_V]
CREATE VIEW [dbo].[CONOPS_EQMT_SHOVEL_HOURLY_SPOTLOADIDLETIME_V]
AS

SELECT 
CASE WHEN site_code = 'CLI' THEN 'CMX' ELSE site_code END AS site_code,
shiftindex,
excav AS Equipment,
avg(idletime) as idletime,
avg(spottime) as spottime,
avg(loadtime) as loadtime
FROM dbo.delta_c WITH (NOLOCK)
GROUP BY site_code,shiftindex,excav

