CREATE VIEW [saf].[zzz_CONOPS_SAF_SHOVEL_SHIFT_TARGET_V] AS






--select * from [saf].[CONOPS_SAF_SHOVEL_SHIFT_TARGET_V] where shiftflag = 'curr'
CREATE VIEW [saf].[zzz_CONOPS_SAF_SHOVEL_SHIFT_TARGET_V]
AS

WITH SINFO AS (
SELECT 
shiftid,
ShiftStartDateTime,
CASE WHEN LEAD(ShiftStartDateTime) OVER ( ORDER BY shiftid ) IS NULL THEN

CASE WHEN RIGHT(shiftid,1) = 2 
THEN concat(dateadd(day,1,cast(LEFT(ShiftStartDateTime,10)as date)),' 06:15:00.000')
ELSE concat(dateadd(day,0,cast(LEFT(ShiftStartDateTime,10)as date)),' 18:15:00.000') END

ELSE LEAD(ShiftStartDateTime) OVER ( ORDER BY shiftid ) END AS ShiftEndDateTime
from [saf].[shift_info] (NOLOCK)),

TGT AS (
SELECT 
shiftid,
shovel,
destination,
sum(shovelshifttarget) as shovelshifttarget
from [saf].[CONOPS_SAF_SHOVEL_TARGET_V]
group by shiftid, shovel,destination),

STGT AS (
SELECT
a.shiftflag,
a.siteflag,
a.shiftid,
tg.shovel,
tg.destination,
tg.shovelshifttarget,
si.ShiftStartDateTime,
si.ShiftEndDateTime,
dateadd(hour,-7,GETUTCDATE()) as current_local_time,
CASE WHEN a.shiftflag = 'PREV' 
THEN datediff(hour,si.ShiftStartDateTime,si.ShiftEndDateTime) 
WHEN a.shiftflag = 'CURR' 
THEN datediff(hour,si.ShiftStartDateTime,dateadd(hour,-7,GETUTCDATE()))
ELSE NULL END as ShiftCompleteHour
FROM saf.CONOPS_SAF_SHIFT_INFO_V a
LEFT JOIN SINFO si on a.shiftid = si.shiftid AND a.siteflag = 'SAF'
LEFT JOIN TGT tg on CAST(a.shiftid AS VARCHAR(20)) = tg.shiftid AND a.siteflag = 'SAF'
WHERE a.siteflag = 'SAF')


SELECT 
siteflag,
shiftflag,
shiftid,
shovel as shovelid,
destination,
shovelshifttarget,
ShiftCompleteHour,

CASE WHEN ShiftCompleteHour IS NULL 
THEN shovelshifttarget ELSE cast((ShiftCompleteHour/12.0)*shovelshifttarget as integer) END as shoveltarget
FROM STGT
WHERE siteflag = 'SAF'

