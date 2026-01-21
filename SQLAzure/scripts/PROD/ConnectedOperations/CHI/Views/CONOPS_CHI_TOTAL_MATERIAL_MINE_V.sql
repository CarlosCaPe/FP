CREATE VIEW [CHI].[CONOPS_CHI_TOTAL_MATERIAL_MINE_V] AS



-- SELECT * FROM [chi].[CONOPS_CHI_TOTAL_MATERIAL_MINE_V] WITH (NOLOCK)
CREATE VIEW [chi].[CONOPS_CHI_TOTAL_MATERIAL_MINE_V]
AS

WITH TONS AS (
   SELECT shiftid,
          SUM([MillOreMined]) AS MillOreActual,
          SUM([ROMLeachMined]) AS ROMLeachActual,
          SUM([CrushedLeachMined]) AS CrushedLeachActual,
          SUM([WasteMined]) AS WasteActual,
		  SUM([TotalMaterialMined]) AS TotalMaterialMined
   FROM [chi].[CONOPS_CHI_SHIFT_OVERVIEW_V]
   GROUP BY shiftid
),

TOTTGT AS (
   SELECT shiftid,
          MillOreShiftTarget/2.0 AS MillOreShiftTarget,
		  ROMLeachShiftTarget/2.0 AS ROMLeachShiftTarget,
		  CrushedLeachShiftTarget/2.0 AS CrushedLeachShiftTarget,
		  WasteShiftTarget/2.0 AS WasteShiftTarget
   FROM (
	  SELECT Right([Year], 2) + FORMAT(CAST([Month] AS numeric), '00') [ShiftId],
  			 DATEEFFECTIVE,
			 siteflag,
			 MillOreShiftTarget,
			 ROMLeachShiftTarget,
			 CrushedLeachShiftTarget,
			 WasteShiftTarget
	  FROM (
		 SELECT DATEEFFECTIVE,
				REVERSE(PARSENAME(REPLACE(REVERSE(DATEEFFECTIVE), '-', '.'), 1)) AS [Year],
				REVERSE(PARSENAME(REPLACE(REVERSE(DATEEFFECTIVE), '-', '.'), 2)) AS [Month],
				'CHI' AS siteflag,
				ISNULL([OreTPD], 0) AS MillOreShiftTarget,
				ISNULL([ROMTPD], 0) AS ROMLeachShiftTarget,
				0 AS CrushedLeachShiftTarget,
				COALESCE([WasteTPD], 0) AS WasteShiftTarget
		 FROM [chi].[PLAN_VALUES] [pv] WITH (NOLOCK)
		 INNER JOIN (
			SELECT MAX(DATEEFFECTIVE) MaxDateEffective
			FROM [chi].[PLAN_VALUES] WITH (NOLOCK)
			WHERE GETDATE() >= DateEffective 
		 ) [maxdate] ON [pv].DateEffective = [maxdate].MaxDateEffective
	  ) [a]
   ) dest
)

SELECT a.shiftflag,
       a.siteflag,
       a.shiftid,
       tn.MillOreActual,
       tn.ROMLeachActual,
       tn.CrushedLeachActual,
       tn.WasteActual,
       tot.MillOreShiftTarget * ((a.ShiftDuration / 3600.00) / 12.) AS MillOreTarget,
       tot.MillOreShiftTarget,
       tot.ROMLeachShiftTarget * ((a.ShiftDuration / 3600.00) / 12) as ROMLeachTarget,
       tot.ROMLeachShiftTarget,
       tot.CrushedLeachShiftTarget * ((a.ShiftDuration / 3600.00) / 12) as CrushedLeachTarget,
       tot.CrushedLeachShiftTarget,
       tot.WasteShiftTarget * ((a.ShiftDuration / 3600.00) / 12) as WasteTarget,
       tot.WasteShiftTarget,
	   tn.TotalMaterialMined
FROM chi.CONOPS_CHI_SHIFT_INFO_V a
LEFT JOIN TONS tn ON a.shiftid = tn.shiftid AND a.siteflag = 'CHI'
LEFT JOIN TOTTGT tot ON LEFT(a.shiftid, 4) >= tot.shiftid AND a.siteflag = 'CHI'
WHERE a.siteflag = 'CHI'


