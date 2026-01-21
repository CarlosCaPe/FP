CREATE VIEW [mor].[CONOPS_MOR_OVERVIEW_V] AS



--select * from [mor].[CONOPS_MOR_OVERVIEW_V]
CREATE VIEW [mor].[CONOPS_MOR_OVERVIEW_V]
AS

WITH TONS AS (
SELECT 
shiftid,
ShovelId, 
TotalMaterialMined,
TotalMineralsMined AS TotalMaterialMoved,
MillOreMined, 
ROMLeachMined, 
CrushedLeachMined, 
TotalMaterialDeliveredToCrusher
FROM [mor].[CONOPS_MOR_SHIFT_OVERVIEW_V]),

TGT AS (
SELECT 
Formatshiftid,
shovel,
sum(ton) as shifttarget
from [mor].[xecute_plan_values] (nolock)
group by Formatshiftid,shovel),

STGT AS (
SELECT
shiftid,
shovelid,
sum(shoveltarget) as shoveltarget
FROM [mor].[CONOPS_MOR_SHOVEL_SHIFT_TARGET_V]
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
tn.TotalMaterialMoved,
tn.MillOreMined, 
tn.ROMLeachMined, 
tn.CrushedLeachMined, 
tn.TotalMaterialDeliveredToCrusher
FROM [mor].[CONOPS_MOR_SHIFT_INFO_V] a
LEFT JOIN TONS tn on tn.shiftid = a.shiftid AND a.siteflag = 'MOR'
LEFT JOIN STGT stg on a.shiftid = stg.shiftid AND stg.shovelid = tn.shovelid AND a.siteflag = 'MOR'
LEFT JOIN TGT tg on a.shiftid = tg.Formatshiftid AND tn.ShovelId = tg.Shovel AND a.siteflag = 'MOR'

WHERE a.siteflag = 'MOR'




