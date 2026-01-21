CREATE VIEW [BAG].[CONOPS_BAG_SHOVEL_SHIFT_TARGET_V] AS


--select * from [bag].[CONOPS_BAG_SHOVEL_SHIFT_TARGET_V] where shiftflag = 'curr'
CREATE VIEW [bag].[CONOPS_BAG_SHOVEL_SHIFT_TARGET_V]
AS


WITH CTE AS (
SELECT
Formatshiftid,
shovel,
destination,
sum(shovelshifttarget) as shovelshifttarget
from [bag].[CONOPS_BAG_SHOVEL_TARGET_V] (NOLOCK)
group by Formatshiftid, shovel,destination)

SELECT
a.siteflag,
a.shiftflag,
a.shiftid,
destination,
Shovel AS shovelid,
shovelshifttarget,
(a.SHIFTDURATION/3600.0) AS ShiftCompleteHour,
CASE WHEN (a.SHIFTDURATION/3600.0) = 0 OR (a.SHIFTDURATION/3600.0) IS NULL THEN 0 
ELSE ((a.SHIFTDURATION/3600.0)/12) * shovelshifttarget END AS ShovelTarget
FROM [bag].[CONOPS_BAG_SHIFT_INFO_V] a
LEFT JOIN CTE b ON a.shiftid = b.FORMATSHIFTID


