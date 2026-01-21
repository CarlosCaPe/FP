CREATE VIEW [cli].[CONOPS_CLI_MINE_PRODUCTIVITY_V] AS





--select * from [cli].[CONOPS_CLI_MINE_PRODUCTIVITY_V] order by shiftid desc
CREATE VIEW [cli].[CONOPS_CLI_MINE_PRODUCTIVITY_V]
AS


WITH TONS AS (

SELECT 
shiftid,
sum(TotalMaterialMined) as totalmineralsmined
from [cli].[CONOPS_CLI_SHIFT_OVERVIEW_V] WITH (NOLOCK)
group by shiftid ),

TGT AS (

SELECT 
shiftid,
sum(shovelshifttarget) as [target],
shiftcompletehour
from [cli].[CONOPS_CLI_SHOVEL_SHIFT_TARGET_V] WITH (NOLOCK)
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
FROM cli.CONOPS_CLI_SHIFT_INFO_V a
LEFT JOIN TONS tn on a.shiftid = tn.shiftid AND a.siteflag = 'CMX'
LEFT JOIN TGT tg on a.shiftid = tg.shiftid AND a.siteflag = 'CMX'

WHERE a.siteflag = 'CMX'

