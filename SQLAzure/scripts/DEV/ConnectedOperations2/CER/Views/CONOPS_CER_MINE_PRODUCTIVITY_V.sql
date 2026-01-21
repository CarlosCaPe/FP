CREATE VIEW [CER].[CONOPS_CER_MINE_PRODUCTIVITY_V] AS




--select * from [cer].[CONOPS_CER_MINE_PRODUCTIVITY_V] WITH (NOLOCK)
CREATE VIEW [cer].[CONOPS_CER_MINE_PRODUCTIVITY_V]
AS


WITH TONS AS (
	SELECT shiftid,
		   SUM(TotalMaterialMined) as TotalMaterialMined
	FROM [cer].[CONOPS_CER_SHIFT_OVERVIEW_V] WITH (NOLOCK)
	GROUP BY shiftid
),

TGT AS (
SELECT DISTINCT
Shiftid,
MaterialMinedShiftTarget AS [Target]
FROM [cer].[CONOPS_CER_SHOVEL_TARGET_V]
)

SELECT a.shiftflag,
	   a.siteflag,
	   a.shiftid,
	   tn.TotalMaterialMined,
	   tg.[target],
	   FLOOR(a.ShiftDuration / 3600) shiftcompletehour,
	   CASE WHEN FLOOR(a.ShiftDuration / 3600) > 0
			THEN tn.TotalMaterialMined/FLOOR(a.ShiftDuration / 3600)
			ELSE 0
	   END AS mineproductivity,
	   tg.[target]/12.0 AS mineproductivitytarget
FROM cer.CONOPS_CER_SHIFT_INFO_V a
LEFT JOIN TONS tn on a.shiftid = tn.shiftid AND a.siteflag = 'CER'
LEFT JOIN TGT tg on a.shiftid = tg.shiftid AND a.siteflag = 'CER'
WHERE a.siteflag = 'CER'



