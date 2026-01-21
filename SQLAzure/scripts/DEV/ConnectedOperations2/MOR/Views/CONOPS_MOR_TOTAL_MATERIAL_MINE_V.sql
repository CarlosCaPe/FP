CREATE VIEW [MOR].[CONOPS_MOR_TOTAL_MATERIAL_MINE_V] AS



CREATE VIEW [mor].[CONOPS_MOR_TOTAL_MATERIAL_MINE_V]
AS

WITH TONS AS (
SELECT 
shiftid,
SUM([MillOreMined]) AS MillOreActual ,
SUM([ROMLeachMined]) AS ROMLeachActual,
SUM([CrushedLeachMined]) AS CrushedLeachActual,
SUM([WasteMined]) AS WasteActual,
SUM([TotalMaterialMined]) AS TotalMaterialMined
FROM [mor].[CONOPS_MOR_SHIFT_OVERVIEW_V]
GROUP BY shiftid),

TGT AS (

select shiftflag,siteflag,shiftid,
case when destination = 'MillOre'then sum(shoveltarget) else 0 end as MillOreTarget,
case when destination = 'MillOre'then sum(shovelshifttarget) else 0 end as MillOreShiftTarget,
case when destination = 'ROMLeach' then sum(shoveltarget) else 0 end as ROMLeachTarget,
case when destination = 'ROMLeach' then sum(shovelshifttarget) else 0 end as ROMLeachShiftTarget,
case when destination = 'CrushLeach' then sum(shoveltarget) else 0 end as CrushedLeachTarget,
case when destination = 'CrushLeach' then sum(shovelshifttarget) else 0 end as CrushedLeachShiftTarget,
case when destination = 'Waste' then sum(shoveltarget) else 0 end as WasteTarget,
case when destination = 'Waste' then sum(shovelshifttarget) else 0 end as WasteShiftTarget
from [mor].[CONOPS_MOR_SHOVEL_SHIFT_TARGET_V] (NOLOCK)
--WHERE siteflag = 'MOR'
group by shiftflag,siteflag,shiftid,destination),

TOTTGT AS (
SELECT shiftflag,siteflag,shiftid,
sum(MillOreTarget) as MillOreTarget,
sum(MillOreShiftTarget) as MillOreShiftTarget,
sum(ROMLeachTarget) as ROMLeachTarget,
sum(ROMLeachShiftTarget) as ROMLeachShiftTarget,
sum(CrushedLeachTarget) as CrushedLeachTarget,
sum(CrushedLeachShiftTarget) as CrushedLeachShiftTarget,
sum(WasteTarget) as WasteTarget,
sum(WasteShiftTarget) as WasteShiftTarget
FROM TGT 
--WHERE siteflag = 'MOR'
group by shiftflag,siteflag,shiftid)

SELECT 
a.shiftflag,
a.siteflag,
a.shiftid,
tn.MillOreActual,
tn.ROMLeachActual,
tn.CrushedLeachActual,
tn.WasteActual,
tot.MillOreTarget,
tot.MillOreShiftTarget,
tot.ROMLeachTarget,
tot.ROMLeachShiftTarget,
tot.CrushedLeachTarget,
tot.CrushedLeachShiftTarget,
tot.WasteTarget,
tot.WasteShiftTarget,
tn.TotalMaterialMined
FROM TONS tn 
LEFT JOIN [mor].[CONOPS_MOR_SHIFT_INFO_V] a on a.shiftid = tn.shiftid --AND a.siteflag = 'MOR'
LEFT JOIN TOTTGT tot on a.shiftid = tot.shiftid --AND a.siteflag = 'MOR'
WHERE a.shiftflag is not null


