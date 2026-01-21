CREATE VIEW [dbo].[CONOPS_LH_OVERALL_DELTA_C_V] AS



CREATE VIEW [dbo].[CONOPS_LH_OVERALL_DELTA_C_V]
AS

SELECT
shiftflag,
siteflag,
shiftid,
delta_c,
DeltaCTarget
FROM [mor].[CONOPS_MOR_OVERALL_DELTA_C_V]
WHERE siteflag = 'MOR'

UNION ALL

SELECT
shiftflag,
siteflag,
shiftid,
delta_c,
DeltaCTarget
FROM [bag].[CONOPS_BAG_OVERALL_DELTA_C_V]
WHERE siteflag = 'BAG'

