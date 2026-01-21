CREATE VIEW [dbo].[CONOPS_LH_DELTA_C_WORST_TRUCK_V] AS


CREATE VIEW [dbo].[CONOPS_LH_DELTA_C_WORST_TRUCK_V]
AS

SELECT 
shiftflag,
siteflag,
shiftid,
truck,
delta_c,
deltac_ts,
DeltaCTarget
FROM [mor].[CONOPS_MOR_DELTA_C_WORST_TRUCK_V]
WHERE siteflag = 'MOR'

UNION ALL


SELECT 
shiftflag,
siteflag,
shiftid,
truck,
delta_c,
deltac_ts,
DeltaCTarget
FROM [bag].[CONOPS_BAG_DELTA_C_WORST_TRUCK_V]
WHERE siteflag = 'BAG'


