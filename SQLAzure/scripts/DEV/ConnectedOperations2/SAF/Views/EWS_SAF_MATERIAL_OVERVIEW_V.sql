CREATE VIEW [SAF].[EWS_SAF_MATERIAL_OVERVIEW_V] AS






--select * from [saf].[EWS_SAF_MATERIAL_OVERVIEW_V] where shiftflag = 'next'
CREATE VIEW [saf].[EWS_SAF_MATERIAL_OVERVIEW_V]
AS

WITH TONS AS (
SELECT 
shiftid,
sum(TotalMaterialMined) AS TotalMaterialMined,
sum(TotalMineralsMined) AS TotalMaterialMoved,
sum(MillOreMined) AS MillOreMined, 
sum(ROMLeachMined) As ROMLeachMined, 
sum(CrushedLeachMined) As CrushedLeachMined
FROM [saf].[CONOPS_SAF_SHIFT_OVERVIEW_V]
GROUP BY shiftid),

TGT AS (
SELECT
shiftid,
case when destination = 'MillOre'then sum(shovelshifttarget) else 0 end as MillOreShiftTarget,
case when destination = 'ROMLeach' then sum(shovelshifttarget) else 0 end as ROMLeachShiftTarget,
case when destination = 'CrushLeach' then sum(shovelshifttarget) else 0 end as CrushedLeachShiftTarget,
case when destination in ('CrushLeach','MillOre') then 0.1 * sum(shovelshifttarget) else 0 end as TransferOreShiftTarget,
sum(shovelshifttarget) as TotalMaterialMinedShiftTarget
FROM [saf].[CONOPS_SAF_SHOVEL_SHIFT_TARGET_V] 
GROUP BY shiftid,destination)


SELECT
a.siteflag,
a.shiftflag,
tn.TotalMaterialMined,
tn.TotalMaterialMoved,
tn.MillOreMined,
tn.ROMLeachMined,
tn.CrushedLeachMined,
sum(tg.TotalMaterialMinedShiftTarget) as TotalMaterialMinedShiftTarget,
CASE WHEN a.ShiftDuration IS NULL OR a.ShiftDuration = 0 THEN 0 ELSE 
sum(tg.TotalMaterialMinedShiftTarget) * ((a.ShiftDuration/3600.0)/12.0) END AS TotalMaterialMinedTarget,
sum(tg.TotalMaterialMinedShiftTarget) + sum(TransferOreShiftTarget) AS TotalMaterialMovedShiftTarget,
CASE WHEN a.ShiftDuration IS NULL OR a.ShiftDuration = 0 THEN 0 ELSE 
(sum(tg.TotalMaterialMinedShiftTarget) + sum(TransferOreShiftTarget)) * ((a.ShiftDuration/3600.0)/12.0) END AS TotalMaterialMovedTarget,
CASE WHEN a.ShiftDuration IS NULL OR a.ShiftDuration = 0 THEN 0 ELSE 
sum(tg.MillOreShiftTarget) * ((a.ShiftDuration/3600.0)/12.0) END as MillOreTarget,
sum(tg.MillOreShiftTarget) as MillOreShiftTarget,
CASE WHEN a.ShiftDuration IS NULL OR a.ShiftDuration = 0 THEN 0 ELSE 
sum(tg.ROMLeachShiftTarget) * ((a.ShiftDuration/3600.0)/12.0) END as ROMLeachTarget,
sum(tg.ROMLeachShiftTarget) as ROMLeachShiftTarget,
CASE WHEN a.ShiftDuration IS NULL OR a.ShiftDuration = 0 THEN 0 ELSE 
sum(tg.CrushedLeachShiftTarget) * ((a.ShiftDuration/3600.0)/12.0) END as CrushedLeachTarget,
sum(tg.CrushedLeachShiftTarget) as CrushedLeachShiftTarget
FROM [saf].CONOPS_SAF_SHIFT_INFO_V a
LEFT JOIN TONS tn ON a.shiftid = tn.shiftid 
LEFT JOIN TGT tg ON a.shiftid = tg.shiftid 


GROUP BY 
a.siteflag,
a.shiftflag,
tn.TotalMaterialMined,
tn.TotalMaterialMoved,
tn.MillOreMined,
tn.ROMLeachMined,
tn.CrushedLeachMined,
a.ShiftDuration



