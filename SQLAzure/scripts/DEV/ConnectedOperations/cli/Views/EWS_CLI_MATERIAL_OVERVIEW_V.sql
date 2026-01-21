CREATE VIEW [cli].[EWS_CLI_MATERIAL_OVERVIEW_V] AS



CREATE VIEW [cli].[EWS_CLI_MATERIAL_OVERVIEW_V]
AS

WITH TONS AS (
SELECT 
shiftid,
sum(TotalExpitMined) AS TotalMaterialMined,
sum(TotalMaterialMined) AS TotalMaterialMoved,
sum(MillOreMined) AS MillOreMined
FROM [cli].[CONOPS_CLI_SHIFT_OVERVIEW_V]
GROUP BY shiftid),

TGT AS (
SELECT
shiftid,
sum(MillOreTarget) as MillOreTarget,
sum(MillOreShiftTarget)as MillOreShiftTarget,
0.1 * (sum(MillOreShiftTarget) + sum(CrusherShiftTarget)) as TransferOreShiftTarget,
sum(shovelshifttarget) as TotalMaterialMinedShiftTarget,
sum(shoveltarget) as TotalMaterialMinedTarget
FROM [cli].[CONOPS_CLI_SHOVEL_SHIFT_TARGET_V] 
GROUP BY shiftid)


SELECT
a.siteflag,
a.shiftflag,
tn.TotalMaterialMined,
tn.TotalMaterialMoved,
tn.MillOreMined,
0 ROMLeachMined,
0 CrushedLeachMined,
0 CrushedLeachTarget,
0 CrushedLeachShiftTarget,
0 ROMLeachTarget,
0 ROMLeachShiftTarget,
TotalMaterialMinedShiftTarget,
TotalMaterialMinedTarget,
sum(tg.TotalMaterialMinedShiftTarget) + sum(TransferOreShiftTarget) AS TotalMaterialMovedShiftTarget,
CASE WHEN a.ShiftDuration IS NULL OR a.ShiftDuration = 0 THEN 0 ELSE 
(sum(tg.TotalMaterialMinedShiftTarget) + sum(TransferOreShiftTarget)) * ((a.ShiftDuration/3600.0)/12.0) END AS TotalMaterialMovedTarget,
MillOreTarget,
MillOreShiftTarget
FROM [cli].CONOPS_CLI_SHIFT_INFO_V a
LEFT JOIN TONS tn ON a.shiftid = tn.shiftid 
LEFT JOIN TGT tg ON a.shiftid = tg.shiftid 


GROUP BY 
a.siteflag,
a.shiftflag,
tn.TotalMaterialMined,
tn.TotalMaterialMoved,
tn.MillOreMined,
a.ShiftDuration,
TotalMaterialMinedShiftTarget,
TotalMaterialMinedTarget,
MillOreTarget,
MillOreShiftTarget


