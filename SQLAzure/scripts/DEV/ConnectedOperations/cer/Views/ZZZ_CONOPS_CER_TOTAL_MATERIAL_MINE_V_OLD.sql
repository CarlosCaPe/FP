CREATE VIEW [cer].[ZZZ_CONOPS_CER_TOTAL_MATERIAL_MINE_V_OLD] AS




-- SELECT * FROM [cer].[CONOPS_CER_TOTAL_MATERIAL_MINE_V] WITH (NOLOCK)
CREATE VIEW [cer].[CONOPS_CER_TOTAL_MATERIAL_MINE_V_OLD]
AS

WITH TONS AS (
   SELECT shiftid,
          SUM([MillOreMined]) AS MillOreActual,
          SUM([ROMLeachMined]) AS ROMLeachActual,
          SUM([CrushedLeachMined]) AS CrushedLeachActual,
          SUM([WasteMined]) AS WasteActual
   FROM [cer].[CONOPS_CER_SHIFT_OVERVIEW_V_OLD]
   GROUP BY shiftid
),

TOTTGT AS (
   SELECT shiftid,
          MillOreShiftTarget,
		  ROMLeachShiftTarget,
		  CrushedLeachShiftTarget,
		  WasteShiftTarget
   FROM (
	  SELECT Right([Year], 2) + FORMAT(CAST([Month] AS numeric), '00') [ShiftId],
			 --siteflag,
			 MillOreShiftTarget,
			 ROMLeachShiftTarget,
			 CrushedLeachShiftTarget,
			 WasteShiftTarget
	  FROM (
		 SELECT REVERSE(PARSENAME(REPLACE(REVERSE(CAST(TITLE AS DATE)), '-', '.'), 1)) AS [Year],
				REVERSE(PARSENAME(REPLACE(REVERSE(CAST(TITLE AS DATE)), '-', '.'), 2)) AS [Month],
				--'CER' AS siteflag,
				ISNULL([TOTALCL], 0) / 2  AS CrushedLeachShiftTarget,
				(ISNULL([TOTALC1], 0) + ISNULL([TOTALC2], 0)) / 2 AS MillOreShiftTarget,
				ISNULL([TOTALROM], 0) / 2 AS ROMLeachShiftTarget,
				ISNULL([TOTALWASTEDELIVERED], 0) / 2 AS WasteShiftTarget
		FROM [cer].[PLAN_VALUES] (nolock) 
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
	   CASE WHEN a.ShiftDuration = 0 THEN 0 ELSE 
       tot.MillOreShiftTarget * ((a.ShiftDuration / 3600.00) / 12.) END AS MillOreTarget,
       tot.MillOreShiftTarget,
	   CASE WHEN a.ShiftDuration = 0 THEN 0 ELSE
       tot.ROMLeachShiftTarget * ((a.ShiftDuration / 3600.00) / 12) END as ROMLeachTarget,
       tot.ROMLeachShiftTarget,
	   CASE WHEN a.ShiftDuration = 0 THEN 0 ELSE
       tot.CrushedLeachShiftTarget * ((a.ShiftDuration / 3600.00) / 12) END as CrushedLeachTarget,
       tot.CrushedLeachShiftTarget,
	   CASE WHEN a.ShiftDuration = 0 THEN 0 ELSE
       tot.WasteShiftTarget * ((a.ShiftDuration / 3600.00) / 12) END as WasteTarget,
       tot.WasteShiftTarget
FROM cer.CONOPS_CER_SHIFT_INFO_V a
LEFT JOIN TONS tn ON a.shiftid = tn.shiftid AND a.siteflag = 'CER'
LEFT JOIN TOTTGT tot ON LEFT(a.shiftid, 4) = tot.shiftid AND a.siteflag = 'CER'
WHERE a.siteflag = 'CER'

