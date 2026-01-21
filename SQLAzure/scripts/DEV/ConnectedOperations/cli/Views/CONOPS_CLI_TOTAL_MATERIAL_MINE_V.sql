CREATE VIEW [cli].[CONOPS_CLI_TOTAL_MATERIAL_MINE_V] AS







CREATE VIEW [cli].[CONOPS_CLI_TOTAL_MATERIAL_MINE_V]
AS

WITH TONS AS (
SELECT 
shiftid,
SUM(MillOreMined) AS MillOreActual ,
0 AS ROMLeachActual,
0 AS CrushedLeachActual,
SUM(WasteMined) AS WasteActual,
SUM([TotalMaterialMined]) AS TotalMaterialMined
FROM [cli].[CONOPS_CLI_SHIFT_OVERVIEW_V]
GROUP BY shiftid),

TGT AS (

select shiftflag,siteflag,shiftid,
MillOreTarget,
MillOreShiftTarget,
0 ROMLeachTarget,
0 ROMLeachShiftTarget,
0 AS CrushedLeachTarget,
0 AS CrushedLeachShiftTarget,
WasteTarget,
WasteShiftTarget
from [cli].[CONOPS_CLI_SHOVEL_SHIFT_TARGET_V] (NOLOCK)
WHERE siteflag = 'CMX'),

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
WHERE siteflag = 'CMX'
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
FROM [cli].[CONOPS_CLI_SHIFT_INFO_V] a
LEFT JOIN TONS tn on a.shiftid = tn.shiftid AND a.siteflag = 'CMX'
LEFT JOIN TOTTGT tot on a.shiftid = tot.shiftid AND a.siteflag = 'CMX'

WHERE a.siteflag = 'CMX'

