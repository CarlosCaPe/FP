CREATE VIEW [Arch].[CONOPS_ARCH_OVERVIEW_V] AS



CREATE VIEW [Arch].[CONOPS_ARCH_OVERVIEW_V]
AS


WITH TONS AS (
SELECT 
shiftid,
ShovelId, 
TotalMaterialMined,
MillOreMined, 
ROMLeachMined, 
CrushedLeachMined, 
TotalMaterialDeliveredToCrusher
FROM [Arch].[CONOPS_ARCH_SHIFT_OVERVIEW_V]),

TGT AS (
SELECT 
Formatshiftid,
shovel,
sum(shovelshifttarget) as shifttarget
from [Arch].[CONOPS_ARCH_SHOVEL_TARGET_V] (nolock)
group by Formatshiftid,shovel),

STGT AS (
SELECT
shiftid,
shovelid,
sum(shoveltarget) as shoveltarget
FROM [Arch].[CONOPS_ARCH_SHOVEL_SHIFT_TARGET_V]
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
tn.MillOreMined, 
tn.ROMLeachMined, 
tn.CrushedLeachMined, 
tn.TotalMaterialDeliveredToCrusher
FROM [dbo].[SHIFT_INFO_V] a
LEFT JOIN TONS tn on tn.shiftid = a.shiftid AND a.siteflag = '<SITECODE>'
LEFT JOIN STGT stg on a.shiftid = stg.shiftid AND stg.shovelid = tn.shovelid AND a.siteflag = '<SITECODE>'
LEFT JOIN TGT tg on a.shiftid = tg.Formatshiftid AND tn.ShovelId = tg.shovel AND a.siteflag = '<SITECODE>'

WHERE a.siteflag = '<SITECODE>'


