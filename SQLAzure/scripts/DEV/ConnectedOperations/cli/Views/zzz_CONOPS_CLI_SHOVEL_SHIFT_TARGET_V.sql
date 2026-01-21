CREATE VIEW [cli].[zzz_CONOPS_CLI_SHOVEL_SHIFT_TARGET_V] AS





--select * from [cli].[CONOPS_CLI_SHOVEL_SHIFT_TARGET_V] where shiftflag = 'curr'

CREATE VIEW [cli].[zzz_CONOPS_CLI_SHOVEL_SHIFT_TARGET_V]
AS

WITH SINFO AS (
SELECT 
shiftid,
ShiftStartDateTime,
CASE WHEN LEAD(ShiftStartDateTime) OVER ( ORDER BY shiftid ) IS NULL THEN

CASE WHEN RIGHT(shiftid,1) = 2 
THEN concat(dateadd(day,1,cast(LEFT(ShiftStartDateTime,10)as date)),' 07:00:00.000')
ELSE concat(dateadd(day,0,cast(LEFT(ShiftStartDateTime,10)as date)),' 19:00:00.000') END

ELSE LEAD(ShiftStartDateTime) OVER ( ORDER BY shiftid ) END AS ShiftEndDateTime
from [cli].[shift_info] (NOLOCK)),


TGT AS (
SELECT 
case when right(shiftid,1) = 1 
THEN concat(right(replace(cast(LEFT(shiftid,CHARINDEX('-', shiftid) - 1) as date),'-',''),6),'001')
ELSE concat(right(replace(cast(LEFT(shiftid,CHARINDEX('-', shiftid) - 1) as date),'-',''),6),'002')
END AS Formatshiftid,
shovel,
sum(WasteTons) As WasteShiftTarget,
sum(TotalTonstoCrusher) AS CrusherShiftTarget,
sum(TotalMillOreMined) AS MillOreShiftTarget,
sum(TotalTonsMined) as shovelshifttarget
from [cli].[plan_values] WITH (NOLOCK)
group by shiftid, shovel),

STGT AS (
SELECT
a.shiftflag,
a.siteflag,
a.shiftid,
tg.shovel,
tg.WasteShiftTarget,
tg.CrusherShiftTarget,
tg.MillOreShiftTarget,
tg.shovelshifttarget,
si.ShiftStartDateTime,
si.ShiftEndDateTime,
dateadd(hour,-7,GETUTCDATE()) as current_local_time,
/*CASE WHEN a.shiftflag = 'PREV' 
THEN datediff(hour,si.ShiftStartDateTime,si.ShiftEndDateTime) 
WHEN a.shiftflag = 'CURR' 
THEN datediff(hour,si.ShiftStartDateTime,dateadd(hour,-7,GETUTCDATE()))
ELSE NULL END as ShiftCompleteHour*/
a.SHIFTDURATION/3600.0 As ShiftCompleteHour
FROM cli.CONOPs_CLI_SHIFT_INFO_V a
LEFT JOIN SINFO si on a.shiftid = si.shiftid AND a.siteflag = 'CMX'
LEFT JOIN TGT tg on a.shiftid = tg.formatshiftid AND a.siteflag = 'CMX'
WHERE a.siteflag = 'CMX')


SELECT 
siteflag,
shiftflag,
shiftid,
shovel as shovelid,
WasteShiftTarget,
CrusherShiftTarget,
MillOreShiftTarget,
shovelshifttarget,
ShiftCompleteHour,

CASE WHEN ShiftCompleteHour = 0
THEN shovelshifttarget ELSE cast((ShiftCompleteHour/12.0)*shovelshifttarget as integer) END as shoveltarget,
CASE WHEN ShiftCompleteHour = 0
THEN shovelshifttarget ELSE cast((ShiftCompleteHour/12.0)*MillOreShiftTarget as integer) END as MillOreTarget,
CASE WHEN ShiftCompleteHour = 0
THEN shovelshifttarget ELSE cast((ShiftCompleteHour/12.0)*WasteShiftTarget as integer) END as WasteTarget,
CASE WHEN ShiftCompleteHour = 0
THEN shovelshifttarget ELSE cast((ShiftCompleteHour/12.0)*CrusherShiftTarget as integer) END as CrusherTarget

FROM STGT
WHERE siteflag = 'CMX'


