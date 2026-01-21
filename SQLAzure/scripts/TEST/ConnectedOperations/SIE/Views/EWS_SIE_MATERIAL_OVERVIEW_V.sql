CREATE VIEW [SIE].[EWS_SIE_MATERIAL_OVERVIEW_V] AS





--select * from [sie].[EWS_SIE_MATERIAL_OVERVIEW_V] where shiftflag = 'next'
CREATE VIEW [sie].[EWS_SIE_MATERIAL_OVERVIEW_V]
AS

WITH TONS AS (
SELECT 
shiftid,
sum(TotalMineralsMined) AS TotalMaterialMined,
sum(TotalMaterialMoved) AS TotalMaterialMoved,
sum(MillOreMined) AS MillOreMined
FROM [sie].[CONOPS_SIE_SHIFT_OVERVIEW_V]
GROUP BY shiftid)

/*TGT AS (
SELECT
shiftid,
case when destination = 'MillOre'then sum(shovelshifttarget) else 0 end as MillOreShiftTarget,
case when destination = 'ROMLeach' then sum(shovelshifttarget) else 0 end as ROMLeachShiftTarget,
case when destination = 'CrushLeach' then sum(shovelshifttarget) else 0 end as CrushedLeachShiftTarget,
case when destination in ('CrushLeach','MillOre') then 0.1 * sum(shovelshifttarget) else 0 end as TransferOreShiftTarget,
sum(shovelshifttarget) as TotalMaterialMinedShiftTarget
FROM [sie].[CONOPS_SIE_SHOVEL_SHIFT_TARGET_V] 
GROUP BY shiftid,destination)*/


SELECT
a.siteflag,
a.shiftflag,
tn.TotalMaterialMined,
tn.TotalMaterialMoved,
tn.MillOreMined,
0 ROMLeachMined,
0 CrushedLeachMined,
0 TotalMaterialMinedShiftTarget,
0 TotalMaterialMinedTarget,
0 TotalMaterialMovedShiftTarget,
0 TotalMaterialMovedTarget,
0 MillOreTarget,
0 MillOreShiftTarget,
0 ROMLeachTarget,
0 ROMLeachShiftTarget,
0 CrushedLeachTarget,
0 CrushedLeachShiftTarget
FROM sie.CONOPS_SIE_SHIFT_INFO_V a
LEFT JOIN TONS tn ON a.shiftid = tn.shiftid 
--LEFT JOIN TGT tg ON a.shiftid = tg.shiftid 


GROUP BY 
a.siteflag,
a.shiftflag,
tn.TotalMaterialMined,
tn.TotalMaterialMoved,
tn.MillOreMined,
a.ShiftDuration



