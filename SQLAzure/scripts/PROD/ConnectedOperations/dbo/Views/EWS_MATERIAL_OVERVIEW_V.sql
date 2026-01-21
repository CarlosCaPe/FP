CREATE VIEW [dbo].[EWS_MATERIAL_OVERVIEW_V] AS



CREATE VIEW [dbo].[EWS_MATERIAL_OVERVIEW_V]
AS

SELECT
siteflag,
shiftflag,
TotalMaterialMined,
TotalMaterialMinedShiftTarget,
TotalMaterialMinedTarget,
TotalMaterialMoved,
TotalMaterialMovedShiftTarget,
TotalMaterialMovedTarget,
MillOreMined,
MillOreTarget,
MillOreShiftTarget,
ROMLeachMined,
ROMLeachTarget,
ROMLeachShiftTarget,
CrushedLeachMined,
CrushedLeachTarget,
CrushedLeachShiftTarget
FROM [mor].[EWS_MOR_MATERIAL_OVERVIEW_V]
WHERE siteflag = 'MOR'


