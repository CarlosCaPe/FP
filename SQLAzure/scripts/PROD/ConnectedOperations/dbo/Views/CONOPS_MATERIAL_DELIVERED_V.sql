CREATE VIEW [dbo].[CONOPS_MATERIAL_DELIVERED_V] AS



--select * from [dbo].[CONOPS_MATERIAL_DELIVERED_V] where siteflag = 'MOR'

CREATE VIEW [dbo].[CONOPS_MATERIAL_DELIVERED_V]
AS


SELECT
'MOR' siteflag,
shiftid,
Truckid,
TotalMaterialDelivered
FROM [mor].[CONOPS_MOR_EQMT_TOTALMATERIALDELIVERED_V]



UNION ALL


SELECT
'BAG' siteflag,
shiftid,
Truckid,
TotalMaterialDelivered
FROM [bag].[CONOPS_BAG_EQMT_TOTALMATERIALDELIVERED_V]




UNION ALL


SELECT
'CHN' siteflag,
shiftid,
Truckid,
TotalMaterialDelivered
FROM [chi].[CONOPS_CHI_EQMT_TOTALMATERIALDELIVERED_V]



UNION ALL


SELECT
'CVE' siteflag,
shiftid,
Truckid,
TotalMaterialDelivered
FROM [cer].[CONOPS_CER_EQMT_TOTALMATERIALDELIVERED_V]



UNION ALL


SELECT
'CMX' siteflag,
shiftid,
Truckid,
TotalMaterialDelivered
FROM [cli].[CONOPS_CLI_EQMT_TOTALMATERIALDELIVERED_V]



UNION ALL


SELECT
'SAM' siteflag,
shiftid,
Truckid,
TotalMaterialDelivered
FROM [saf].[CONOPS_SAF_EQMT_TOTALMATERIALDELIVERED_V]



UNION ALL


SELECT
'SIE' siteflag,
shiftid,
Truckid,
TotalMaterialDelivered
FROM [sie].[CONOPS_SIE_EQMT_TOTALMATERIALDELIVERED_V]



UNION ALL


SELECT
'TYR' siteflag,
shiftid,
Truckid,
TotalMaterialDelivered
FROM [tyr].[CONOPS_TYR_EQMT_TOTALMATERIALDELIVERED_V]


UNION ALL


SELECT
'ABR' siteflag,
shiftid,
Truckid,
TotalMaterialDelivered
FROM [abr].[CONOPS_ABR_EQMT_TOTALMATERIALDELIVERED_V]






