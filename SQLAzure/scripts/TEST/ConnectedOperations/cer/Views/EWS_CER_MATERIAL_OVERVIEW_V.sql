CREATE VIEW [cer].[EWS_CER_MATERIAL_OVERVIEW_V] AS







--select * from [cer].[EWS_CER_MATERIAL_OVERVIEW_V] where shiftflag = 'next'
CREATE VIEW [cer].[EWS_CER_MATERIAL_OVERVIEW_V]
AS

WITH TONS AS (
SELECT 
shiftid,
sum(TotalMaterialMined) AS TotalMaterialMined,
sum(TotalMaterialMoved) AS TotalMaterialMoved,
sum(MillMined) AS MillOreMined, 
sum(ROMMined) As ROMLeachMined, 
sum(CrushLeachMined) As CrushedLeachMined
FROM [cer].[CONOPS_CER_SHIFT_OVERVIEW_V]
GROUP BY shiftid),


TGT AS (
SELECT shiftid,
          MillOreShiftTarget,
		  ROMLeachShiftTarget,
		  CrushedLeachShiftTarget,
		  TotalmaterialMovedShiftTarget,
		  TotalmaterialMinedShiftTarget
   FROM (
	  SELECT Right([Year], 2) + FORMAT(CAST([Month] AS numeric), '00') [ShiftId],
			 --siteflag,
			 MillOreShiftTarget,
			 ROMLeachShiftTarget,
			 CrushedLeachShiftTarget,
			 TotalmaterialMovedShiftTarget,
			 TotalmaterialMinedShiftTarget
	  FROM (
		 SELECT REVERSE(PARSENAME(REPLACE(REVERSE(CAST(TITLE AS DATE)), '-', '.'), 1)) AS [Year],
				REVERSE(PARSENAME(REPLACE(REVERSE(CAST(TITLE AS DATE)), '-', '.'), 2)) AS [Month],
				--'CER' AS siteflag,
				ISNULL([TOTALCL], 0) / 2  AS CrushedLeachShiftTarget,
				(ISNULL([TOTALC1], 0) + ISNULL([TOTALC2], 0)) / 2 AS MillOreShiftTarget,
				ISNULL([TOTALROM], 0) / 2 AS ROMLeachShiftTarget,
				ISNULL(TOTALMATERIALMINED, 0) / 2 AS TotalmaterialMinedShiftTarget,
				ISNULL(TOTALMATERIALMOVED, 0) / 2 AS TotalmaterialMovedShiftTarget
		FROM [cer].[PLAN_VALUES] (nolock) 
	  ) [a]
   ) dest)


SELECT
a.siteflag,
a.shiftflag,
tn.TotalMaterialMined,
tn.TotalMaterialMoved,
tn.MillOreMined,
tn.ROMLeachMined,
tn.CrushedLeachMined,
sum(tg.TotalMaterialMinedShiftTarget) as TotalMaterialMinedShiftTarget,
CASE WHEN a.ShiftDuration IS NULL OR a.ShiftDuration = 0 THEN 0 ELSE 
sum(tg.TotalMaterialMinedShiftTarget) * ((a.ShiftDuration/3600.0)/12.0) END AS TotalMaterialMinedTarget,
sum(TotalmaterialMovedShiftTarget) AS TotalMaterialMovedShiftTarget,
CASE WHEN a.ShiftDuration IS NULL OR a.ShiftDuration = 0 THEN 0 ELSE 
sum(TotalmaterialMovedShiftTarget) * ((a.ShiftDuration/3600.0)/12.0) END AS TotalMaterialMovedTarget,
CASE WHEN a.ShiftDuration IS NULL OR a.ShiftDuration = 0 THEN 0 ELSE 
sum(tg.MillOreShiftTarget) * ((a.ShiftDuration/3600.0)/12.0) END AS MillOreTarget,
sum(tg.MillOreShiftTarget) as MillOreShiftTarget,
CASE WHEN a.ShiftDuration IS NULL OR a.ShiftDuration = 0 THEN 0 ELSE 
sum(tg.ROMLeachShiftTarget) * ((a.ShiftDuration/3600.0)/12.0) END AS ROMLeachTarget,
sum(tg.ROMLeachShiftTarget) as ROMLeachShiftTarget,
CASE WHEN a.ShiftDuration IS NULL OR a.ShiftDuration = 0 THEN 0 ELSE 
sum(tg.CrushedLeachShiftTarget) * ((a.ShiftDuration/3600.0)/12.0) END AS CrushedLeachTarget,
sum(tg.CrushedLeachShiftTarget) as CrushedLeachShiftTarget
FROM [cer].CONOPS_CER_SHIFT_INFO_V a
LEFT JOIN TONS tn ON a.shiftid = tn.shiftid 
LEFT JOIN TGT tg ON LEFT(a.shiftid, 4) = tg.shiftid 


GROUP BY 
a.siteflag,
a.shiftflag,
tn.TotalMaterialMined,
tn.TotalMaterialMoved,
tn.MillOreMined,
tn.ROMLeachMined,
tn.CrushedLeachMined,
a.ShiftDuration



