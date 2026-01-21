CREATE VIEW [dbo].[CONOPS_MATERIAL_MINED_V] AS

--select * from [dbo].[CONOPS_MATERIAL_MINED_V] where siteflag = 'MOR'

CREATE VIEW [dbo].[CONOPS_MATERIAL_MINED_V]
AS


SELECT
'MOR' siteflag,
shiftid,
ShovelId,
TotalMaterialMined,
TotalMaterialMoved
FROM [mor].[CONOPS_MOR_EQMT_TOTALMATERIALMINED_V]



UNION ALL


SELECT
'BAG' siteflag,
shiftid,
ShovelId,
TotalMaterialMined,
TotalMaterialMoved
FROM [bag].[CONOPS_BAG_EQMT_TOTALMATERIALMINED_V]




UNION ALL


SELECT
'CHN' siteflag,
shiftid,
ShovelId,
TotalMaterialMined,
TotalMaterialMoved
FROM [chi].[CONOPS_CHI_EQMT_TOTALMATERIALMINED_V]



UNION ALL


SELECT
'CVE' siteflag,
shiftid,
ShovelId,
TotalMaterialMined,
TotalMaterialMoved
FROM [cer].[CONOPS_CER_EQMT_TOTALMATERIALMINED_V]



UNION ALL


SELECT
'CMX' siteflag,
shiftid,
ShovelId,
TotalMaterialMined,
TotalMaterialMoved
FROM [cli].[CONOPS_CLI_EQMT_TOTALMATERIALMINED_V]



UNION ALL


SELECT
'SAM' siteflag,
shiftid,
ShovelId,
TotalMaterialMined,
TotalMaterialMoved
FROM [saf].[CONOPS_SAF_EQMT_TOTALMATERIALMINED_V]



UNION ALL


SELECT
'SIE' siteflag,
shiftid,
ShovelId,
TotalMaterialMined,
TotalMaterialMoved
FROM [sie].[CONOPS_SIE_EQMT_TOTALMATERIALMINED_V]


UNION ALL


SELECT
'TYR' siteflag,
shiftid,
ShovelId,
TotalMaterialMined,
TotalMaterialMoved
FROM [tyr].[CONOPS_TYR_EQMT_TOTALMATERIALMINED_V]


UNION ALL


SELECT
'ABR' siteflag,
shiftid,
ShovelId,
TotalMaterialMined,
TotalMaterialMoved
FROM [abr].[CONOPS_ABR_EQMT_TOTALMATERIALMINED_V]





