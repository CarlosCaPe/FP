CREATE VIEW [cer].[ZZZ_CONOPS_CER_MATERIAL_DELIVERED_TO_CHRUSHER_V_BUP] AS


--select * from [cer].[CONOPS_CER_MATERIAL_DELIVERED_TO_CHRUSHER_V]
CREATE VIEW [cer].[CONOPS_CER_MATERIAL_DELIVERED_TO_CHRUSHER_V]
AS

WITH CTE AS (
SELECT shiftid,
       --'CER' AS siteflag,
	   [loc] AS CrusherLoc,
	   SUM(CASE WHEN loc in ('MILLCHAN', 'HIDRO-C1', 'MILLCRUSH1', 'MILLCRUSH2')
				THEN lfTons
                ELSE 0
           END) AS MillOre,
       SUM(CASE WHEN loc in ('HIDROCHAN')
				THEN lfTons
				ELSE 0
           END) AS CrusherLeach,
       COUNT(lfTons) AS TotalNrDumps
FROM (
	  SELECT IIF(locs.FieldId = 'HIDRO-C1', 'MILLCHAN', locs.FieldId) AS loc,
             dumps.FieldLSizeTons AS [LfTons],
             dumps.ShiftId
      FROM [cer].SHIFT_DUMP dumps WITH (NOLOCK)
      LEFT JOIN CER.shift_loc locs WITH(NOLOCK) ON locs.ShiftId=dumps.ShiftId
      AND locs.shift_loc_id =dumps.FieldLoc
      WHERE locs.FieldId in ('MILLCHAN', 'HIDRO-C1', 'MILLCRUSH1',
                             'MILLCRUSH2', 'HIDROCHAN')
) AS Consolidated
GROUP BY shiftid, loc)

SELECT
a.shiftflag,
a.siteflag,
a.shiftid,
b.CrusherLoc,
b.MillOre,
b.CrusherLeach,
b.TotalNrDumps
FROM [cer].[CONOPS_CER_SHIFT_INFO_V] a
LEFT JOIN CTE b ON a.shiftid = b.shiftid 

