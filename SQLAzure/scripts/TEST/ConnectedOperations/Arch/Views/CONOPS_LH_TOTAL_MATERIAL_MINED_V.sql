CREATE VIEW [Arch].[CONOPS_LH_TOTAL_MATERIAL_MINED_V] AS





--select * from [Arch].[CONOPS_LH_TOTAL_MATERIAL_MINED_V]
CREATE VIEW [Arch].[CONOPS_LH_TOTAL_MATERIAL_MINED_V]
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
FROM [Arch].[CONOPS_ARCH_TOTAL_MATERIAL_MINE_V]


