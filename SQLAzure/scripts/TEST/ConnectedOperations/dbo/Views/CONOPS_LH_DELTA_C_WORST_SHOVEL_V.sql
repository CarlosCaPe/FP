CREATE VIEW [dbo].[CONOPS_LH_DELTA_C_WORST_SHOVEL_V] AS



--select * from [dbo].[CONOPS_LH_DELTA_C_WORST_SHOVEL_V] where shiftflag = 'prev' and siteflag = 'mor' order by truck,delta_c desc
CREATE VIEW [dbo].[CONOPS_LH_DELTA_C_WORST_SHOVEL_V]
AS

SELECT 
shiftflag,
siteflag,
shiftid,
excav,
delta_c,
deltac_ts,
DeltaCTarget
FROM [mor].[CONOPS_MOR_DELTA_C_WORST_SHOVEL_V]
WHERE siteflag = 'MOR'

UNION ALL


SELECT 
shiftflag,
siteflag,
shiftid,
excav,
delta_c,
deltac_ts,
DeltaCTarget
FROM [bag].[CONOPS_BAG_DELTA_C_WORST_SHOVEL_V]
WHERE siteflag = 'BAG'

UNION ALL

SELECT 
shiftflag,
siteflag,
shiftid,
excav,
delta_c,
deltac_ts,
DeltaCTarget
FROM [saf].[CONOPS_SAF_DELTA_C_WORST_SHOVEL_V]
WHERE siteflag = 'SAF'


UNION ALL


SELECT 
shiftflag,
siteflag,
shiftid,
excav,
delta_c,
deltac_ts,
DeltaCTarget
FROM [sie].[CONOPS_SIE_DELTA_C_WORST_SHOVEL_V]
WHERE siteflag = 'SIE'

UNION ALL


SELECT 
shiftflag,
siteflag,
shiftid,
excav,
delta_c,
deltac_ts,
DeltaCTarget
FROM [cli].[CONOPS_CLI_DELTA_C_WORST_SHOVEL_V]
WHERE siteflag = 'CMX'

UNION ALL

SELECT 
shiftflag,
siteflag,
shiftid,
excav,
delta_c,
deltac_ts,
DeltaCTarget
FROM [chi].[CONOPS_CHI_DELTA_C_WORST_SHOVEL_V]
WHERE siteflag = 'CHI'


UNION ALL

SELECT 
shiftflag,
siteflag,
shiftid,
excav,
delta_c,
deltac_ts,
DeltaCTarget
FROM [cer].[CONOPS_CER_DELTA_C_WORST_SHOVEL_V]
WHERE siteflag = 'CER'
