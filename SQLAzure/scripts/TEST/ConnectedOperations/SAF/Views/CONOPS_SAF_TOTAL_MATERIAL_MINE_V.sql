CREATE VIEW [SAF].[CONOPS_SAF_TOTAL_MATERIAL_MINE_V] AS






-- SELECT * FROM [saf].[CONOPS_SAF_TOTAL_MATERIAL_MINE_V] WITH (NOLOCK)
CREATE VIEW [saf].[CONOPS_SAF_TOTAL_MATERIAL_MINE_V]
AS

WITH TONS AS (
   SELECT shiftid,
          SUM([MillOreMined]) AS MillOreActual,
          SUM([ROMLeachMined]) AS ROMLeachActual,
          SUM([CrushedLeachMined]) AS CrushedLeachActual,
          SUM([WasteMined]) AS WasteActual,
		  SUM([TotalMaterialMined]) AS TotalMaterialMined
   FROM [saf].[CONOPS_SAF_SHIFT_OVERVIEW_V]
   GROUP BY shiftid
),

TGT AS (
   SELECT shiftflag,
          siteflag,
          shiftid,
          CASE
              WHEN destination = 'MillOre'THEN sum(shoveltarget)
              ELSE 0
          END AS MillOreTarget,
          CASE
              WHEN destination = 'MillOre'THEN sum(shovelshifttarget)
              ELSE 0
          END AS MillOreShiftTarget,
          CASE
              WHEN destination = 'ROMLeach' THEN sum(shoveltarget)
              ELSE 0
          END AS ROMLeachTarget,
          CASE
              WHEN destination = 'ROMLeach' THEN sum(shovelshifttarget)
              ELSE 0
          END AS ROMLeachShiftTarget,
          CASE
              WHEN destination = 'CrushLeach' THEN sum(shoveltarget)
              ELSE 0
          END AS CrushedLeachTarget,
          CASE
              WHEN destination = 'CrushLeach' THEN sum(shovelshifttarget)
              ELSE 0
          END AS CrushedLeachShiftTarget,
          CASE
              WHEN destination = 'Waste' THEN sum(shoveltarget)
              ELSE 0
          END AS WasteTarget,
          CASE
              WHEN destination = 'Waste' THEN sum(shovelshifttarget)
              ELSE 0
          END AS WasteShiftTarget
   FROM [saf].[CONOPS_SAF_SHOVEL_SHIFT_TARGET_V] (NOLOCK)
   WHERE siteflag = 'SAF'
   GROUP BY shiftflag, siteflag, shiftid, destination
),

TOTTGT AS (
   SELECT shiftflag,
          siteflag,
          shiftid,
          sum(MillOreTarget) AS MillOreTarget,
          sum(MillOreShiftTarget) AS MillOreShiftTarget,
          sum(ROMLeachTarget) AS ROMLeachTarget,
          sum(ROMLeachShiftTarget) AS ROMLeachShiftTarget,
          sum(CrushedLeachTarget) AS CrushedLeachTarget,
          sum(CrushedLeachShiftTarget) AS CrushedLeachShiftTarget,
          sum(WasteTarget) AS WasteTarget,
          sum(WasteShiftTarget) AS WasteShiftTarget
   FROM TGT
   WHERE siteflag = 'SAF'
   GROUP BY shiftflag, siteflag, shiftid
)

SELECT a.shiftflag,
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
FROM saf.CONOPS_SAF_SHIFT_INFO_V a
LEFT JOIN TONS tn ON a.shiftid = tn.shiftid 
LEFT JOIN TOTTGT tot ON a.shiftid = tot.shiftid 



