CREATE VIEW [sie].[CONOPS_SIE_TOTAL_MATERIAL_MINE_V] AS




--select * from [sie].[CONOPS_SIE_TOTAL_MATERIAL_MINE_V]
CREATE VIEW [sie].[CONOPS_SIE_TOTAL_MATERIAL_MINE_V]
AS

WITH TONS AS (
SELECT 
shiftid,
SUM(MillOreMined) AS MillOreActual ,
0 AS ROMLeachActual,
0 AS CrushedLeachActual,
--SUM(TotalWasteMoved) AS WasteActual
SUM(WasteMined) AS WasteActual,
SUM([TotalMineralsMined]) AS TotalMaterialMined
FROM [sie].[CONOPS_SIE_SHIFT_OVERVIEW_V]
GROUP BY shiftid),

TGT AS (
SELECT 
shiftflag,
CASE WHEN destination IN ( 'Crusher', 'V Ore', 'Stk6' )THEN 'Ore' ELSE 'Waste' END AS destination,
ShovelShiftTarget,
shoveltarget
FROM [sie].[CONOPS_SIE_SHOVEL_SHIFT_TARGET_V]),

FinalTarget AS (
SELECT
shiftflag,
CASE WHEN destination = 'Ore' THEN SUM(shoveltarget) END AS MillOreTarget,
CASE WHEN destination = 'Ore' THEN SUM(ShovelShiftTarget) END AS MillOreShiftTarget,
CASE WHEN destination = 'Waste' THEN SUM(shoveltarget) END AS WasteTarget,
CASE WHEN destination = 'Waste' THEN SUM(ShovelShiftTarget) END AS WasteShiftTarget
FROM TGT
--WHERE shiftflag = 'curr'
GROUP BY shiftflag,destination),

Final AS (
SELECT
shiftflag,
SUM(MillOreTarget) AS MillOreTarget,
SUM(MillOreShiftTarget) AS MillOreShiftTarget,
SUM(WasteTarget) AS WasteTarget,
SUM(WasteShiftTarget) WasteShiftTarget
FROM FinalTarget
GROUP BY Shiftflag)

SELECT 
a.shiftflag,
a.siteflag,
a.shiftid,
tn.MillOreActual,
tn.ROMLeachActual,
tn.CrushedLeachActual,
tn.WasteActual,
MillOreTarget,
MillOreShiftTarget,
0 ROMLeachTarget,
0 ROMLeachShiftTarget,
0 CrushedLeachTarget,
0 CrushedLeachShiftTarget,
WasteTarget,
WasteShiftTarget,
tn.TotalMaterialMined
FROM [sie].[CONOPS_SIE_SHIFT_INFO_V] a
LEFT JOIN TONS tn on a.shiftid = tn.shiftid
LEFT JOIN Final tot on a.shiftflag = tot.shiftflag 




