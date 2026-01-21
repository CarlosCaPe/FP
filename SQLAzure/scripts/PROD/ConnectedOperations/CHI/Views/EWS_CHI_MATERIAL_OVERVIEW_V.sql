CREATE VIEW [CHI].[EWS_CHI_MATERIAL_OVERVIEW_V] AS



--select * from [chi].[EWS_CHI_MATERIAL_OVERVIEW_V] where shiftflag = 'next'
CREATE VIEW [CHI].[EWS_CHI_MATERIAL_OVERVIEW_V]
AS

WITH TONS AS (
SELECT 
shiftid,
sum(TotalMaterialMined) AS TotalMaterialMined,
0 AS TotalMaterialMoved,
sum(MillOreMined) AS MillOreMined, 
sum(ROMLeachMined) As ROMLeachMined, 
--sum(TotalMaterialDeliveredtoCrusher) As CrushedLeachMined
0 As CrushedLeachMined
FROM [chi].[CONOPS_CHI_SHIFT_OVERVIEW_V]
GROUP BY shiftid),

TGT AS (
SELECT shiftid,
          MillOreShiftTarget,
		  ROMLeachShiftTarget,
		  CrushedLeachShiftTarget,
		  TotalMaterialMinedShiftTarget
   FROM (
	  SELECT Right([Year], 2) + FORMAT(CAST([Month] AS numeric), '00') [ShiftId],
  			 DATEEFFECTIVE,
			 MillOreShiftTarget,
			 ROMLeachShiftTarget,
			 CrushedLeachShiftTarget,
			 TotalMaterialMinedShiftTarget
	  FROM (
		 SELECT DATEEFFECTIVE,
				REVERSE(PARSENAME(REPLACE(REVERSE(DATEEFFECTIVE), '-', '.'), 1)) AS [Year],
				REVERSE(PARSENAME(REPLACE(REVERSE(DATEEFFECTIVE), '-', '.'), 2)) AS [Month],
				ISNULL([OreTPD], 0) AS MillOreShiftTarget,
				ISNULL([ROMTPD], 0) AS ROMLeachShiftTarget,
				0 AS CrushedLeachShiftTarget,
				ISNULL(TotalExPitTPD, 0) AS TotalMaterialMinedShiftTarget
		 FROM [chi].[PLAN_VALUES] [pv] WITH (NOLOCK)
		 INNER JOIN (
			SELECT MAX(DATEEFFECTIVE) MaxDateEffective
			FROM [chi].[PLAN_VALUES] WITH (NOLOCK)
			WHERE GETDATE() >= DateEffective 
		 ) [maxdate] ON [pv].DateEffective = [maxdate].MaxDateEffective
	  ) [a]
   ) dest
)


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
0 TotalMaterialMovedShiftTarget,
0 TotalMaterialMovedTarget,
CASE WHEN a.ShiftDuration IS NULL OR a.ShiftDuration = 0 THEN 0 ELSE 
sum(tg.MillOreShiftTarget) * ((a.ShiftDuration/3600.0)/12.0) END AS MillOreTarget,
sum(tg.MillOreShiftTarget) as MillOreShiftTarget,
CASE WHEN a.ShiftDuration IS NULL OR a.ShiftDuration = 0 THEN 0 ELSE 
sum(tg.ROMLeachShiftTarget) * ((a.ShiftDuration/3600.0)/12.0) END AS ROMLeachTarget,
sum(tg.ROMLeachShiftTarget) as ROMLeachShiftTarget,
CASE WHEN a.ShiftDuration IS NULL OR a.ShiftDuration = 0 THEN 0 ELSE 
sum(tg.CrushedLeachShiftTarget) * ((a.ShiftDuration/3600.0)/12.0) END AS CrushedLeachTarget,
sum(tg.CrushedLeachShiftTarget) as CrushedLeachShiftTarget
FROM [chi].CONOPS_CHI_SHIFT_INFO_V a
LEFT JOIN TONS tn ON a.shiftid = tn.shiftid 
LEFT JOIN TGT tg ON LEFT(a.shiftid, 4) >= tg.shiftid 


GROUP BY 
a.siteflag,
a.shiftflag,
tn.TotalMaterialMined,
tn.TotalMaterialMoved,
tn.MillOreMined,
tn.ROMLeachMined,
tn.CrushedLeachMined,
a.ShiftDuration




