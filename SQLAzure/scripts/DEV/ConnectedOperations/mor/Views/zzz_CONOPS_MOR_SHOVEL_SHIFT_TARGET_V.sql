CREATE VIEW [mor].[zzz_CONOPS_MOR_SHOVEL_SHIFT_TARGET_V] AS




--select * from [mor].[CONOPS_MOR_SHOVEL_SHIFT_TARGET_V] where shiftflag = 'curr'
CREATE VIEW [mor].[zzz_CONOPS_MOR_SHOVEL_SHIFT_TARGET_V]
AS

WITH SINFO AS (
SELECT 
shiftid,
ShiftStartDateTime,
CASE WHEN LEAD(ShiftStartDateTime) OVER ( ORDER BY shiftid ) IS NULL THEN

CASE WHEN RIGHT(shiftid,1) = 2 
THEN concat(dateadd(day,1,cast(LEFT(ShiftStartDateTime,10)as date)),' 07:15:00.000')
ELSE concat(dateadd(day,0,cast(LEFT(ShiftStartDateTime,10)as date)),' 19:15:00.000') END

ELSE LEAD(ShiftStartDateTime) OVER ( ORDER BY shiftid ) END AS ShiftEndDateTime
from [mor].[shift_info] (NOLOCK)),

TGT AS (
SELECT 
case when right(shiftid,1) = 1 
THEN concat(right(replace(cast(LEFT(shiftid,CHARINDEX('-', shiftid) - 1) as date),'-',''),6),'001')
ELSE concat(right(replace(cast(LEFT(shiftid,CHARINDEX('-', shiftid) - 1) as date),'-',''),6),'002')
END AS Formatshiftid,
shovel,
case when destination NOT IN ('STC9999', 'IPC3M') AND destination NOT LIKE '%L4' THEN 'ROMLeach'
when destination = 'STC9999' THEN 'CrushLeach'
when destination = 'IPC3M' THEN 'MillOre'
when destination IN ('MOL5965L','WCP3700L') THEN 'Waste'
ELSE destination END AS destination,
sum(tons) as shovelshifttarget
from [mor].[plan_values] (NOLOCK)
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
FROM mor.CONOPS_MOR_SHIFT_INFO_V a
LEFT JOIN SINFO si on a.shiftid = si.shiftid AND a.siteflag = 'MOR'
LEFT JOIN TGT tg on a.shiftid = tg.formatshiftid AND a.siteflag = 'MOR'
WHERE a.siteflag = 'MOR')


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
WHERE siteflag = 'MOR'

