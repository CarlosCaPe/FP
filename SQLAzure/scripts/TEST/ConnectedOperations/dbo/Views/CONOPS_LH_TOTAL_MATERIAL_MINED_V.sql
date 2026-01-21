CREATE VIEW [dbo].[CONOPS_LH_TOTAL_MATERIAL_MINED_V] AS





--select * from [dbo].[CONOPS_LH_TOTAL_MATERIAL_MINED_V]
CREATE VIEW [dbo].[CONOPS_LH_TOTAL_MATERIAL_MINED_V]
AS

SELECT
shiftflag,
siteflag,
shiftid,
MillOreActual,
MillOreTarget,
MillOreShiftTarget,
ROMLeachActual,
ROMLeachTarget,
ROMLeachShiftTarget,
CrushedLeachActual,
CrushedLeachTarget,
CrushedLeachShiftTarget,
WasteActual,
WasteTarget,
WasteShiftTarget
FROM [mor].[CONOPS_MOR_TOTAL_MATERIAL_MINE_V]
WHERE siteflag = 'MOR'

UNION ALL


SELECT
shiftflag,
siteflag,
shiftid,
MillOreActual,
MillOreTarget,
MillOreShiftTarget,
ROMLeachActual,
ROMLeachTarget,
ROMLeachShiftTarget,
CrushedLeachActual,
CrushedLeachTarget,
CrushedLeachShiftTarget,
WasteActual,
WasteTarget,
WasteShiftTarget
FROM [bag].[CONOPS_BAG_TOTAL_MATERIAL_MINE_V]
WHERE siteflag = 'BAG'

UNION ALL

SELECT
shiftflag,
siteflag,
shiftid,
MillOreActual,
MillOreTarget,
MillOreShiftTarget,
ROMLeachActual,
ROMLeachTarget,
ROMLeachShiftTarget,
CrushedLeachActual,
CrushedLeachTarget,
CrushedLeachShiftTarget,
WasteActual,
WasteTarget,
WasteShiftTarget
FROM [saf].[CONOPS_SAF_TOTAL_MATERIAL_MINE_V]
WHERE siteflag = 'SAF'


UNION ALL


SELECT
shiftflag,
siteflag,
shiftid,
MillOreActual,
MillOreTarget,
MillOreShiftTarget,
ROMLeachActual,
ROMLeachTarget,
ROMLeachShiftTarget,
CrushedLeachActual,
CrushedLeachTarget,
CrushedLeachShiftTarget,
WasteActual,
WasteTarget,
WasteShiftTarget
FROM [sie].[CONOPS_SIE_TOTAL_MATERIAL_MINE_V]
WHERE siteflag = 'SIE'



UNION ALL


SELECT
shiftflag,
siteflag,
shiftid,
MillOreActual,
MillOreTarget,
MillOreShiftTarget,
ROMLeachActual,
ROMLeachTarget,
ROMLeachShiftTarget,
CrushedLeachActual,
CrushedLeachTarget,
CrushedLeachShiftTarget,
WasteActual,
WasteTarget,
WasteShiftTarget
FROM [cli].[CONOPS_CLI_TOTAL_MATERIAL_MINE_V]
WHERE siteflag = 'CMX'

UNION ALL

SELECT
shiftflag,
siteflag,
shiftid,
MillOreActual,
MillOreTarget,
MillOreShiftTarget,
ROMLeachActual,
ROMLeachTarget,
ROMLeachShiftTarget,
CrushedLeachActual,
CrushedLeachTarget,
CrushedLeachShiftTarget,
WasteActual,
WasteTarget,
WasteShiftTarget
FROM [chi].[CONOPS_CHI_TOTAL_MATERIAL_MINE_V]
WHERE siteflag = 'CHI'

UNION ALL

SELECT
shiftflag,
siteflag,
shiftid,
MillOreActual,
MillOreTarget,
MillOreShiftTarget,
ROMLeachActual,
ROMLeachTarget,
ROMLeachShiftTarget,
CrushedLeachActual,
CrushedLeachTarget,
CrushedLeachShiftTarget,
WasteActual,
WasteTarget,
WasteShiftTarget
FROM [cer].[CONOPS_CER_TOTAL_MATERIAL_MINE_V]
WHERE siteflag = 'CER'




