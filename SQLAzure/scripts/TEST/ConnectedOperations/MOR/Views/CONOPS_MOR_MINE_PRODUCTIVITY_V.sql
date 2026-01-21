CREATE VIEW [MOR].[CONOPS_MOR_MINE_PRODUCTIVITY_V] AS




--select * from [mor].[CONOPS_MOR_MINE_PRODUCTIVITY_V] order by shiftid desc
CREATE VIEW [mor].[CONOPS_MOR_MINE_PRODUCTIVITY_V]
AS


WITH TONS AS (

SELECT 
shiftid,
sum(totalmineralsmined) as totalmineralsmined
from [mor].[CONOPS_MOR_SHIFT_OVERVIEW_V] WITH (NOLOCK)
group by shiftid ),

TGT AS (

SELECT 
shiftid,
sum(shovelshifttarget) as [target],
shiftcompletehour
from [mor].[CONOPS_MOR_SHOVEL_SHIFT_TARGET_V] WITH (NOLOCK)
GROUP BY siteflag,shiftflag,shiftid,shiftcompletehour)

SELECT
a.shiftflag,
a.siteflag,
a.shiftid,
tn.totalmineralsmined,
tg.[target],
tg.shiftcompletehour,
CASE WHEN tg.shiftcompletehour > 0 THEN tn.totalmineralsmined/tg.shiftcompletehour
ELSE 0 END AS mineproductivity,
tg.[target]/12.0 AS mineproductivitytarget
FROM mor.CONOPS_MOR_SHIFT_INFO_V a
LEFT JOIN TONS tn on a.shiftid = tn.shiftid AND a.siteflag = 'MOR'
LEFT JOIN TGT tg on a.shiftid = tg.shiftid AND a.siteflag = 'MOR'

WHERE a.siteflag = 'MOR'

