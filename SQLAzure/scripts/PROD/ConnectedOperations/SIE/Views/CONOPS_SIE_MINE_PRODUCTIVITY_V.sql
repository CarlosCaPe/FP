CREATE VIEW [SIE].[CONOPS_SIE_MINE_PRODUCTIVITY_V] AS


--select * from [sie].[CONOPS_SIE_MINE_PRODUCTIVITY_V] order by shiftid desc
CREATE VIEW [sie].[CONOPS_SIE_MINE_PRODUCTIVITY_V]
AS


WITH TONS AS (

SELECT 
shiftid,
sum(TotalMaterialMoved) as totalmineralsmined
from [sie].[CONOPS_SIE_SHIFT_OVERVIEW_V] WITH (NOLOCK)
group by shiftid ),

TGT AS (

SELECT 
shiftflag,
sum(shovelshifttarget) as [target]
from [sie].[CONOPS_SIE_SHOVEL_SHIFT_TARGET_V] WITH (NOLOCK)
GROUP BY shiftflag)

SELECT
a.shiftflag,
a.siteflag,
a.shiftid,
tn.totalmineralsmined,
tg.[target],
a.SHIFTDURATION/3600.0 AS shiftcompletehour,
CASE WHEN a.SHIFTDURATION > 0 THEN tn.totalmineralsmined/(a.SHIFTDURATION/3600.0)
ELSE 0 END AS mineproductivity,
tg.[target]/12.0 AS mineproductivitytarget
FROM sie.CONOPS_SIE_SHIFT_INFO_V a
LEFT JOIN TONS tn on a.shiftid = tn.shiftid
LEFT JOIN TGT tg on a.shiftflag = tg.shiftflag



