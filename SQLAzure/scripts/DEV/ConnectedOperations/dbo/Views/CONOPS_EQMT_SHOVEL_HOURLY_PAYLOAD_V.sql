CREATE VIEW [dbo].[CONOPS_EQMT_SHOVEL_HOURLY_PAYLOAD_V] AS




--select * from [dbo].[CONOPS_EQMT_SHOVEL_HOURLY_PAYLOAD_V] 
CREATE VIEW [dbo].[CONOPS_EQMT_SHOVEL_HOURLY_PAYLOAD_V]
AS


SELECT  
shiftindex,
CASE WHEN site_code = 'CLI' THEN 'CMX' ELSE site_code END AS site_code,
excav AS Equipment,
avg(measureton) as payload
FROM dbo.lh_load WITH (nolock)
GROUP BY shiftindex, site_code, excav


