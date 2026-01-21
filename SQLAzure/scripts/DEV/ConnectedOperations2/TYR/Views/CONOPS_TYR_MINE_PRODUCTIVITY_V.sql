CREATE VIEW [TYR].[CONOPS_TYR_MINE_PRODUCTIVITY_V] AS




--select * from [tyr].[CONOPS_TYR_MINE_PRODUCTIVITY_V] WITH (NOLOCK)
CREATE VIEW [TYR].[CONOPS_TYR_MINE_PRODUCTIVITY_V]
AS


WITH TONS AS (
	SELECT shiftid,
		   SUM(TotalMaterialMined) as totalmineralsmined
	FROM [tyr].[CONOPS_TYR_SHIFT_OVERVIEW_V] WITH (NOLOCK)
	GROUP BY shiftid
),

TGT AS (
SELECT 
shiftid,
sum(shovelshifttarget) as [target]
from [tyr].[CONOPS_TYR_SHOVEL_SHIFT_TARGET_V] WITH (NOLOCK)
GROUP BY siteflag,shiftid)

SELECT a.shiftflag,
	   a.siteflag,
	   a.shiftid,
	   tn.totalmineralsmined,
	   tg.[target],
	   FLOOR(a.ShiftDuration / 3600) shiftcompletehour,
	   CASE WHEN FLOOR(a.ShiftDuration / 3600) > 0
			THEN tn.totalmineralsmined/FLOOR(a.ShiftDuration / 3600)
			ELSE 0
	   END AS mineproductivity,
	   tg.[target]/12.0 AS mineproductivitytarget
FROM [tyr].CONOPS_TYR_SHIFT_INFO_V a
LEFT JOIN TONS tn on a.shiftid = tn.shiftid 
LEFT JOIN TGT tg on a.shiftid = tg.shiftid 



