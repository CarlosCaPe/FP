CREATE VIEW [TYR].[CONOPS_TYR_TOTAL_MATERIAL_MINE_V] AS





-- SELECT * FROM [tyr].[CONOPS_TYR_TOTAL_MATERIAL_MINE_V] WITH (NOLOCK)
CREATE VIEW [TYR].[CONOPS_TYR_TOTAL_MATERIAL_MINE_V]
AS
---Tyron only have ROM and Waste
WITH TONS AS (
   SELECT shiftid,
          SUM([MillOreMined]) AS MillOreActual,
          SUM([ROMLeachMined]) AS ROMLeachActual,
          SUM([CrushedLeachMined]) AS CrushedLeachActual,
          SUM([WasteMined]) AS WasteActual,
		  SUM([TotalMaterialMined]) AS TotalMaterialMined
   FROM [tyr].[CONOPS_TYR_SHIFT_OVERVIEW_V]
   GROUP BY shiftid
),

TOTTGT AS (
SELECT
ShiftId,
CASE WHEN destination = 'Waste' THEN SUM(ShovelTarget) END AS WasteTarget,
CASE WHEN destination = 'ROM' THEN SUM(ShovelTarget) END AS ROMTarget,
CASE WHEN destination = 'Waste' THEN SUM(ShovelShiftTarget) END AS WasteShiftTarget,
CASE WHEN destination = 'ROM' THEN SUM(ShovelShiftTarget) END AS ROMShiftTarget
FROM [TYR].[CONOPS_TYR_SHOVEL_SHIFT_TARGET_V]
GROUP BY ShiftId,destination
)

SELECT a.shiftflag,
       a.siteflag,
       a.shiftid,
       tn.MillOreActual,
       tn.ROMLeachActual,
       tn.CrushedLeachActual,
       tn.WasteActual,
	   0 MillOreTarget,
	   0 MillOreShiftTarget,
       SUM(tot.ROMTarget) AS ROMTarget,
       SUM(tot.ROMShiftTarget) AS ROMShiftTarget,
	   0 CrushedLeachTarget,
	   0 CrushedLeachShiftTarget,
       SUM(tot.WasteTarget) AS WasteTarget,
       SUM(tot.WasteShiftTarget) AS WasteShiftTarget,
	   tn.TotalMaterialMined
FROM [tyr].[CONOPS_TYR_SHIFT_INFO_V] a
LEFT JOIN TONS tn ON a.shiftid = tn.shiftid 
LEFT JOIN TOTTGT tot ON a.shiftid = tot.shiftid
GROUP BY 
a.shiftflag,
a.siteflag,
a.shiftid,
tn.MillOreActual,
tn.ROMLeachActual,
tn.CrushedLeachActual,
tn.WasteActual,
tn.TotalMaterialMined



