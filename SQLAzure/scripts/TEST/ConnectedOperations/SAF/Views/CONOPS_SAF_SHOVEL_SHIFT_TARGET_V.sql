CREATE VIEW [SAF].[CONOPS_SAF_SHOVEL_SHIFT_TARGET_V] AS


--select * from [saf].[CONOPS_SAF_SHOVEL_SHIFT_TARGET_V] where shiftflag = 'curr'
CREATE VIEW [saf].[CONOPS_SAF_SHOVEL_SHIFT_TARGET_V]
AS

WITH CTE AS (
SELECT 
shiftid,
shovel,
destination,
sum(shovelshifttarget) as shovelshifttarget
from [saf].[CONOPS_SAF_SHOVEL_TARGET_V]
group by shiftid, shovel,destination)


SELECT
siteflag,
shiftflag,
a.shiftid,
shovel as shovelid,
destination,
shovelshifttarget,
(ShiftDuration/3600.0) AS ShiftCompleteHour,
((ShiftDuration/3600.0)/12.0) * shovelshifttarget AS ShovelTarget
FROM [saf].[CONOPS_SAF_SHIFT_INFO_V] a
LEFT JOIN CTE b ON a.shiftid = b.shiftid

