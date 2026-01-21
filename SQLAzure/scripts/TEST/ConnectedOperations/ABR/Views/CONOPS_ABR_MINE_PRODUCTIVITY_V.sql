CREATE VIEW [ABR].[CONOPS_ABR_MINE_PRODUCTIVITY_V] AS



--select * from [abr].[CONOPS_ABR_MINE_PRODUCTIVITY_V] WITH (NOLOCK)
CREATE VIEW [ABR].[CONOPS_ABR_MINE_PRODUCTIVITY_V]
AS


WITH TONS AS (
	SELECT shiftid,
		   SUM(TotalMaterialMined) as totalmineralsmined
	FROM [abr].[CONOPS_ABR_SHIFT_OVERVIEW_V] WITH (NOLOCK)
	GROUP BY shiftid
)

SELECT a.shiftflag,
	   a.siteflag,
	   a.shiftid,
	   tn.totalmineralsmined,
	   ShovelShiftTarget AS [target],
	   FLOOR(a.ShiftDuration / 3600) shiftcompletehour,
	   CASE WHEN FLOOR(a.ShiftDuration / 3600) > 0
			THEN tn.totalmineralsmined/FLOOR(a.ShiftDuration / 3600)
			ELSE 0
	   END AS mineproductivity,
	   tg.ShovelShiftTarget/12.0 AS mineproductivitytarget
FROM [abr].CONOPS_ABR_SHIFT_INFO_V a
LEFT JOIN TONS tn on a.shiftid = tn.shiftid 
LEFT JOIN [ABR].[CONOPS_ABR_SHOVEL_SHIFT_TARGET_V] tg on a.shiftid = tg.shiftid 


