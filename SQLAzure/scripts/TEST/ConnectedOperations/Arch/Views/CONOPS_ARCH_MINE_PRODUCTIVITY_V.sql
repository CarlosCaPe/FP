CREATE VIEW [Arch].[CONOPS_ARCH_MINE_PRODUCTIVITY_V] AS



CREATE VIEW [Arch].[CONOPS_ARCH_MINE_PRODUCTIVITY_V]
AS


WITH TONS AS (

SELECT 
shiftid,
sum(TotalMaterialMined) as totalmineralsmined
from [Arch].[CONOPS_ARCH_SHIFT_OVERVIEW_V] WITH (NOLOCK)
group by shiftid ),

TGT AS (

SELECT 
siteflag,
shiftflag,
shiftid,
shiftcompletehour
from [Arch].[CONOPS_ARCH_SHOVEL_SHIFT_TARGET_V] 
GROUP BY siteflag,shiftflag,shiftid,shiftcompletehour),

ST AS (
SELECT
shiftid,
sum(shifttarget) as [target]
FROM [Arch].[CONOPS_ARCH_SHIFT_TARGET_V]
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
FROM dbo.SHIFT_INFO_V a
LEFT JOIN TONS tn on a.shiftid = tn.shiftid AND a.siteflag = '<SITECODE>'
LEFT JOIN TGT tg on a.shiftid = tg.shiftid AND a.siteflag = '<SITECODE>'
LEFT JOIN ST st on a.shiftid = st.shiftid AND a.siteflag = '<SITECODE>'

WHERE a.siteflag = '<SITECODE>'

