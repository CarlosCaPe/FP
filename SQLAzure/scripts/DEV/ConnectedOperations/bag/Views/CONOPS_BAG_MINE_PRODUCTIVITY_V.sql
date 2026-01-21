CREATE VIEW [bag].[CONOPS_BAG_MINE_PRODUCTIVITY_V] AS




--select * from [bag].[CONOPS_BAG_MINE_PRODUCTIVITY_V] order by shiftid desc
CREATE VIEW [bag].[CONOPS_BAG_MINE_PRODUCTIVITY_V]
AS


WITH TONS AS (

SELECT 
shiftid,
sum(TotalMaterialMined) as totalmineralsmined
from [bag].[CONOPS_BAG_SHIFT_OVERVIEW_V] WITH (NOLOCK)
group by shiftid ),

TGT AS (

SELECT 
shiftid,
--sum(shovelshifttarget) as [target],
shiftcompletehour
from [bag].[CONOPS_BAG_SHOVEL_SHIFT_TARGET_V] 
GROUP BY siteflag,shiftflag,shiftid,shiftcompletehour),

ST AS (
SELECT
shiftid,
sum(shifttarget) as [target]
FROM [bag].[CONOPS_BAG_SHIFT_TARGET_V]
group by shiftid)

SELECT
a.shiftflag,
a.siteflag,
a.shiftid,
tn.totalmineralsmined,
st.[target],
tg.shiftcompletehour,
CASE WHEN tg.shiftcompletehour > 0 THEN tn.totalmineralsmined/tg.shiftcompletehour
ELSE 0 END AS mineproductivity,
st.[target]/12.0 AS mineproductivitytarget
FROM bag.CONOPS_BAG_SHIFT_INFO_V a
LEFT JOIN TONS tn on a.shiftid = tn.shiftid AND a.siteflag = 'BAG'
LEFT JOIN TGT tg on a.shiftid = tg.shiftid AND a.siteflag = 'BAG'
LEFT JOIN ST st on a.shiftid = st.shiftid AND a.siteflag = 'BAG'

WHERE a.siteflag = 'BAG'

