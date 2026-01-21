CREATE VIEW [sie].[CONOPS_SIE_OVERVIEW_V] AS



--select * from [sie].[CONOPS_SIE_OVERVIEW_V] where shiftflag = 'prev' order by shovelid
CREATE VIEW [sie].[CONOPS_SIE_OVERVIEW_V]
AS


WITH TONS AS (
SELECT 
shiftid,
ShovelId, 
SUM(TotalMaterialMoved) AS TotalMaterialMoved,
SUM(TotalMineralsMined) AS TotalMaterialMined,
SUM(MillOreMined) MillOreMined, 
0 AS ROMLeachMined, 
0 AS CrushedLeachMined, 
SUM(TotalMaterialDeliveredToCrusher) TotalMaterialDeliveredToCrusher
FROM [sie].[CONOPS_SIE_SHIFT_OVERVIEW_V]
GROUP BY shiftid,ShovelId),

TGT AS (
SELECT 
shiftflag,
shovelid,
SUM(shovelshifttarget) as shifttarget,
SUM(shoveltarget) AS shoveltarget
from [sie].[CONOPS_SIE_SHOVEL_SHIFT_TARGET_V]
GROUP BY shiftflag,shovelid
)

SELECT 
a.shiftflag,
a.siteflag,
a.shiftid,
a.shiftindex,
tn.ShovelId, 
shoveltarget,
shifttarget,
tn.TotalMaterialMined,
tn.TotalMaterialMoved,
tn.MillOreMined, 
tn.ROMLeachMined, 
tn.CrushedLeachMined, 
tn.TotalMaterialDeliveredToCrusher
FROM [sie].[CONOPS_SIE_SHIFT_INFO_V] a
LEFT JOIN TONS tn on tn.shiftid = a.shiftid
LEFT JOIN TGT tg on a.shiftflag = tg.shiftflag AND tn.ShovelId = tg.shovelid





