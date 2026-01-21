CREATE VIEW [ABR].[CONOPS_ABR_TOTAL_MATERIAL_MINE_V] AS





-- SELECT * FROM [abr].[CONOPS_ABR_TOTAL_MATERIAL_MINE_V] WITH (NOLOCK)
CREATE VIEW [ABR].[CONOPS_ABR_TOTAL_MATERIAL_MINE_V]
AS

WITH TONS AS (
   SELECT shiftid,
          SUM([MillOreMined]) AS MillOreActual,
          SUM([ROMLeachMined]) AS ROMLeachActual,
          SUM([CrushedLeachMined]) AS CrushedLeachActual,
          SUM([WasteMined]) AS WasteActual,
		  SUM([TotalMaterialMined]) AS TotalMaterialMined
   FROM [abr].[CONOPS_ABR_SHIFT_OVERVIEW_V]
   GROUP BY shiftid
),

TGT AS (
select shiftflag,siteflag,shiftid,
case when destination = 'MillOre'then sum(shoveltarget) else 0 end as MillOreTarget,
case when destination = 'MillOre'then sum(shovelshifttarget) else 0 end as MillOreShiftTarget,
case when destination = 'ROMLeach' then sum(shoveltarget) else 0 end as ROMLeachTarget,
case when destination = 'ROMLeach' then sum(shovelshifttarget) else 0 end as ROMLeachShiftTarget,
0 AS CrushedLeachTarget,
0 AS CrushedLeachShiftTarget,
case when destination = 'Waste' then sum(shoveltarget) else 0 end as WasteTarget,
case when destination = 'Waste' then sum(shovelshifttarget) else 0 end as WasteShiftTarget
from [abr].[CONOPS_ABR_SHOVEL_SHIFT_TARGET_V] (NOLOCK)
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
group by shiftflag,siteflag,shiftid)


SELECT 
	a.shiftflag,
	a.siteflag,
	a.shiftid,
	tn.MillOreActual,
	tn.ROMLeachActual,
	0 CrushedLeachActual,
	tn.WasteActual,
	tot.MillOreTarget,
	tot.MillOreShiftTarget,
	tot.ROMLeachTarget,
	tot.ROMLeachShiftTarget,
	0 CrushedLeachTarget,
	0 CrushedLeachShiftTarget,
	tot.WasteTarget,
	tot.WasteShiftTarget,
	tn.TotalMaterialMined
FROM [abr].CONOPS_ABR_SHIFT_INFO_V a
LEFT JOIN TONS tn on a.shiftid = tn.shiftid 
LEFT JOIN TOTTGT tot on a.shiftid = tot.shiftid 




