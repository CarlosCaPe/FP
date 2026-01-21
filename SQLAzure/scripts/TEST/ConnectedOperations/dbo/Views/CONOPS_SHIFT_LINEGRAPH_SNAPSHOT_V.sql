CREATE VIEW [dbo].[CONOPS_SHIFT_LINEGRAPH_SNAPSHOT_V] AS



--select * from [dbo].[CONOPS_SHIFT_LINEGRAPH_SNAPSHOT_V] where siteflag = 'MOR'
CREATE VIEW [dbo].[CONOPS_SHIFT_LINEGRAPH_SNAPSHOT_V]
AS


SELECT
'MOR' siteflag,
shiftid,
shovelid,
SUM(TotalMaterialMined) AS TotalMaterialMined,
SUM(TotalMineralsMined) AS TotalMaterialMoved,
SUM(wastemined) AS Waste,
SUM(MillOreMined) AS Mill,
SUM(CrushedLeachMined) AS CrushLeach,
SUM(ROMLeachMined) AS ROM
FROM [mor].[CONOPS_MOR_SHIFT_OVERVIEW_V]
GROUP BY shiftid, shovelid


UNION ALL


SELECT
'BAG' siteflag,
shiftid,
shovelid,
SUM(TotalMaterialMined) AS TotalMaterialMined,
SUM(TotalMaterialMoved) AS TotalMaterialMoved,
SUM(wastemined) AS Waste,
SUM(MillOreMined) AS Mill,
0 CrushLeach,
0 ROM
FROM [bag].[CONOPS_BAG_SHIFT_OVERVIEW_V]
GROUP BY shiftid, shovelid



UNION ALL


SELECT
'CHN' siteflag,
shiftid,
shovelid,
SUM(TotalMaterialMined) AS TotalMaterialMined,
SUM(TotalMaterialMoved) AS TotalMaterialMoved,
SUM(WasteMined) AS Waste,
SUM(MillOreMined) AS Mill,
0 CrushLeach,
SUM(ROMLeachMined) AS ROM
FROM [chi].[CONOPS_CHI_SHIFT_OVERVIEW_V]
GROUP BY shiftid, shovelid


UNION ALL


SELECT
'CVE' siteflag,
shiftid,
shovelid,
SUM(TotalMaterialMined) AS TotalMaterialMined,
SUM(TotalMaterialMoved) AS TotalMaterialMoved,
SUM(WasteMined) AS Waste,
SUM(MillMined) AS Mill,
0 CrushLeach,
SUM(ROMMined) AS ROM
FROM [cer].[CONOPS_CER_SHIFT_OVERVIEW_V]
GROUP BY shiftid, shovelid


UNION ALL


SELECT
'CMX' siteflag,
shiftid,
shovelid,
SUM(TotalMaterialMined) AS TotalMaterialMined,
SUM(TotalMaterialMoved) AS TotalMaterialMoved,
SUM(WasteMined) AS Waste,
SUM(MillOreMined) AS Mill,
0 CrushLeach,
0 ROM
FROM [cli].[CONOPS_CLI_SHIFT_OVERVIEW_V]
GROUP BY shiftid, shovelid


UNION ALL


SELECT
'SAM' siteflag,
shiftid,
shovelid,
SUM(TotalMineralsMined) AS TotalMaterialMined,
0 TotalMaterialMoved,
SUM(WasteMined) AS Waste,
0 Mill,
SUM(CrushedLeachMined) AS CrushLeach,
0 ROM
FROM [saf].[CONOPS_SAF_SHIFT_OVERVIEW_V]
GROUP BY shiftid, shovelid


UNION ALL


SELECT
'SIE' siteflag,
shiftid,
shovelid,
SUM(TotalMineralsMined) AS TotalMaterialMined,
0 TotalMaterialMoved,
SUM(WasteMined) AS Waste,
SUM(MillOreMined) AS Mill,
0 CrushLeach,
0 ROM
FROM [sie].[CONOPS_SIE_SHIFT_OVERVIEW_V]
GROUP BY shiftid, shovelid


UNION ALL


SELECT
'TYR' siteflag,
shiftid,
shovelid,
SUM(TotalMaterialMined) AS TotalMaterialMined,
SUM(TotalMaterialMoved) AS TotalMaterialMoved,
SUM(WasteMined) AS Waste,
0 AS Mill,
0 CrushLeach,
SUM(ROMLeachMined) AS ROM
FROM [TYR].[CONOPS_TYR_SHIFT_OVERVIEW_V]
GROUP BY shiftid, shovelid



UNION ALL


SELECT
'ABR' siteflag,
shiftid,
shovelid,
SUM(TotalMaterialMined) AS TotalMaterialMined,
SUM(TotalMaterialMoved) AS TotalMaterialMoved,
SUM(WasteMined) AS Waste,
0 AS Mill,
0 CrushLeach,
SUM(ROMLeachMined) AS ROM
FROM [ABR].[CONOPS_ABR_SHIFT_OVERVIEW_V]
GROUP BY shiftid, shovelid






