CREATE VIEW [dbo].[CONOPS_LH_TOTAL_MATERIAL_MINED_V] AS


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


