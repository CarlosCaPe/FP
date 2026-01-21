CREATE VIEW [cli].[CONOPS_CLI_OVERVIEW_V] AS


--select * from [cli].[CONOPS_CLI_OVERVIEW_V]
CREATE VIEW [cli].[CONOPS_CLI_OVERVIEW_V]
AS


WITH TONS AS (
SELECT 
shiftid,
ShovelId, 
TotalMaterialMined,
TotalMaterialMoved,
MillOreMined, 
0 AS ROMLeachMined, 
0 AS CrushedLeachMined, 
TotalMaterialDeliveredToCrusher
FROM [cli].[CONOPS_CLI_SHIFT_OVERVIEW_V]),

TGT AS (
SELECT 
shiftid,
shovelId,
sum(shovelshifttarget) as shifttarget
from [cli].[CONOPS_CLI_SHOVEL_SHIFT_TARGET_V] (nolock)
group by shiftid,shovelId),

STGT AS (
SELECT
shiftid,
shovelid,
sum(shoveltarget) as shoveltarget
FROM [cli].[CONOPS_CLI_SHOVEL_SHIFT_TARGET_V]
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
tn.MillOreMined, 
tn.ROMLeachMined, 
tn.CrushedLeachMined, 
tn.TotalMaterialDeliveredToCrusher
FROM [cli].[CONOPS_CLI_SHIFT_INFO_V] a
LEFT JOIN TONS tn on tn.shiftid = a.shiftid 
LEFT JOIN STGT stg on a.shiftid = stg.shiftid AND stg.shovelid = tn.shovelid 
LEFT JOIN TGT tg on a.shiftid = tg.shiftid AND tn.ShovelId = tg.shovelId 



