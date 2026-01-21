CREATE VIEW [dbo].[CONOPS_LH_OVERALL_DELTA_C_V] AS




--select * from [dbo].[CONOPS_LH_OVERALL_DELTA_C_V]
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

UNION ALL

SELECT
shiftflag,
siteflag,
shiftid,
delta_c,
DeltaCTarget
FROM [saf].[CONOPS_SAF_OVERALL_DELTA_C_V]
WHERE siteflag = 'SAF'

UNION ALL

SELECT
shiftflag,
siteflag,
shiftid,
delta_c,
DeltaCTarget
FROM [cli].[CONOPS_CLI_OVERALL_DELTA_C_V]
WHERE siteflag = 'CMX'


UNION ALL

SELECT
shiftflag,
siteflag,
shiftid,
delta_c,
DeltaCTarget
FROM [sie].[CONOPS_SIE_OVERALL_DELTA_C_V]
WHERE siteflag = 'SIE'

UNION ALL

SELECT
shiftflag,
siteflag,
shiftid,
delta_c,
DeltaCTarget
FROM [chi].[CONOPS_CHI_OVERALL_DELTA_C_V]
WHERE siteflag = 'CHI'


UNION ALL

SELECT
shiftflag,
siteflag,
shiftid,
delta_c,
DeltaCTarget
FROM [cer].[CONOPS_CER_OVERALL_DELTA_C_V]
WHERE siteflag = 'CER'
