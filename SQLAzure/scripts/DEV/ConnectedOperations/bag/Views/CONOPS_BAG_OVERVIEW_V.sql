CREATE VIEW [bag].[CONOPS_BAG_OVERVIEW_V] AS


--select * from [bag].[CONOPS_BAG_OVERVIEW_V]
CREATE VIEW [bag].[CONOPS_BAG_OVERVIEW_V]
AS


WITH TONS AS (
SELECT 
shiftid,
ShovelId, 
TotalMaterialMined,
TotalMaterialMoved,
MillOreMined, 
ROMLeachMined, 
CrushedLeachMined, 
TotalMaterialDeliveredToCrusher
FROM [bag].[CONOPS_BAG_SHIFT_OVERVIEW_V]),

TGT AS (
SELECT 
Formatshiftid,
shovel,
sum(shovelshifttarget) as shifttarget
from [bag].[CONOPS_BAG_SHOVEL_TARGET_V] (nolock)
group by Formatshiftid,shovel),

STGT AS (
SELECT
shiftid,
shovelid,
sum(shoveltarget) as shoveltarget
FROM [bag].[CONOPS_BAG_SHOVEL_SHIFT_TARGET_V]
GROUP BY shiftid,shovelid)


SELECT 
a.shiftflag,
a.siteflag,
a.shiftid,
a.shiftindex,
tn.ShovelId, 
stg.shoveltarget,
tg.shifttarget,
tn.TotalMaterialMined,
TotalMaterialMoved,
tg.shifttarget AS TotalMaterialMovedShiftTarget,
stg.shoveltarget AS TotalMaterialMovedTarget,
tn.MillOreMined, 
tn.ROMLeachMined, 
tn.CrushedLeachMined, 
tn.TotalMaterialDeliveredToCrusher
FROM [bag].[CONOPS_BAG_SHIFT_INFO_V] a
LEFT JOIN TONS tn on tn.shiftid = a.shiftid 
LEFT JOIN STGT stg on a.shiftid = stg.shiftid AND stg.shovelid = tn.shovelid 
LEFT JOIN TGT tg on a.shiftid = tg.Formatshiftid AND tn.ShovelId = tg.shovel 



