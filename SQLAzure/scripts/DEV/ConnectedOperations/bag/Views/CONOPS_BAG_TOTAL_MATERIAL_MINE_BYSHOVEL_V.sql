CREATE VIEW [bag].[CONOPS_BAG_TOTAL_MATERIAL_MINE_BYSHOVEL_V] AS
  
  
CREATE VIEW [bag].[CONOPS_BAG_TOTAL_MATERIAL_MINE_BYSHOVEL_V]  
AS  
  
WITH TONS AS (  
SELECT   
shiftid,  
shovelid,
SUM([MillOreMined]) AS MillOreActual ,  
SUM([ROMLeachMined]) AS ROMLeachActual,  
SUM([CrushedLeachMined]) AS CrushedLeachActual,  
SUM([WasteMined]) AS WasteActual
FROM [bag].[CONOPS_BAG_SHIFT_OVERVIEW_V]  
GROUP BY shiftid,shovelid)  

/*
TGT AS (  
  
SELECT 
shiftflag,
siteflag,
shiftid,  
shovelid,
CASE WHEN destination = 'MillOre'THEN SUM(shoveltarget) ELSE 0 END AS MillOreTarget,  
CASE WHEN destination = 'MillOre'THEN SUM(shovelshifttarget) ELSE 0 END AS MillOreShiftTarget,  
CASE WHEN destination = 'ROMLeach' THEN SUM(shoveltarget) ELSE 0 END AS ROMLeachTarget,  
CASE WHEN destination = 'ROMLeach' THEN SUM(shovelshifttarget) ELSE 0 END AS ROMLeachShiftTarget,  
0 AS CrushedLeachTarget,  
0 AS CrushedLeachShiftTarget,  
CASE WHEN destination = 'Waste' THEN SUM(shoveltarget) ELSE 0 END AS WasteTarget,  
CASE WHEN destination = 'Waste' THEN SUM(shovelshifttarget) ELSE 0 END AS WasteShiftTarget  
FROM [bag].[CONOPS_BAG_SHOVEL_SHIFT_TARGET_V] WITH (NOLOCK)  
group by shiftflag,siteflag,shiftid,destination,shovelid),  
  
TOTTGT AS (  
SELECT 
shiftflag,
siteflag,
shiftid,  
shovelid,
SUM(MillOreTarget) as MillOreTarget,  
SUM(MillOreShiftTarget) as MillOreShiftTarget,  
SUM(ROMLeachTarget) as ROMLeachTarget,  
SUM(ROMLeachShiftTarget) as ROMLeachShiftTarget,  
SUM(CrushedLeachTarget) as CrushedLeachTarget,  
SUM(CrushedLeachShiftTarget) as CrushedLeachShiftTarget,  
SUM(WasteTarget) as WasteTarget,  
SUM(WasteShiftTarget) as WasteShiftTarget  
FROM TGT   
group by shiftflag,siteflag,shiftid,shovelid) 
*/
  
SELECT   
a.shiftflag,  
a.siteflag,  
a.shiftid,  
tn.shovelid,
tn.MillOreActual,  
0 ROMLeachActual,  
0 CrushedLeachActual,  
tn.WasteActual,  
--tot.MillOreTarget,  
--tot.MillOreShiftTarget,  
0 ROMLeachTarget,  
0 ROMLeachShiftTarget,  
0 CrushedLeachTarget,  
0 CrushedLeachShiftTarget
--tot.WasteTarget,  
--tot.WasteShiftTarget
FROM [bag].[CONOPS_BAG_SHIFT_INFO_V] a  
LEFT JOIN TONS tn on a.shiftid = tn.shiftid
--LEFT JOIN TOTTGT tot on a.shiftid = tot.shiftid AND tn.shovelid = tot.shovelid
  