CREATE VIEW [mor].[zzz_CONOPS_MOR_EQMT_TRUCK_HOURLY_TOTALMATERIALDELIVERED_V] AS



--select * from [mor].[CONOPS_MOR_EQMT_TRUCK_HOURLY_TOTALMATERIALDELIVERED_V]
CREATE VIEW [mor].[zzz_CONOPS_MOR_EQMT_TRUCK_HOURLY_TOTALMATERIALDELIVERED_V]
AS

WITH CTE AS (
SELECT 
dumps.shiftid,
SSE.fieldid AS Truckid,
SSE.[FieldSize] AS [Tons],
dateadd(second,dumps.fieldtimedump,sinfo.shiftstartdatetime) as shiftdumptime
FROM mor.shift_dump_v dumps WITH (NOLOCK)
LEFT JOIN mor.shift_eqmt SSE WITH (NOLOCK) ON SSE.Id = dumps.FieldTruck AND SSE.ShiftId = dumps.[OrigShiftid]
LEFT JOIN mor.shift_loc loc WITH  (NOLOCK)  ON loc.Id = dumps.FieldLoc
LEFT JOIN mor.Enum enums WITH (nolock)  ON enums.Id = dumps.FieldLoad
LEFT JOIN (
SELECT shiftid, ShiftStartDateTime,LEAD(ShiftStartDateTime) 
OVER ( ORDER BY shiftid ) AS ShiftEndDateTime 
from mor.[shift_info]) sinfo ON dumps.shiftid = sinfo.shiftid
WHERE enums.Idx NOT IN ( 26, 27, 28, 29, 30 )
AND loc.FieldId IN ( 'C2MIL', 'C3MIL', 'C2MFL', 'C3MFL' )),


Material AS (
SELECT
shiftflag,
siteflag,
ShiftStartDateTime,
TruckId,
SUM(Tons) AS TotalMaterialDelivered,
CASE WHEN datediff(minute, a.ShiftStartDateTime,c.shiftdumptime) 
between b.starts and b.ends THEN b.seq ELSE '999999' END AS shiftseq
FROM [mor].[CONOPS_MOR_SHIFT_INFO_V] a 
CROSS JOIN [dbo].[HOURLY_TIME_SEQ] b
LEFT JOIN CTE c
ON a.shiftid = c.shiftid
GROUP BY shiftflag, siteflag,truckid,shiftdumptime, b.starts, b.ends, b.seq,ShiftStartDateTime),

Final AS (
SELECT
shiftflag,
siteflag,
ShiftStartDateTime,
TruckId,
SUM(TotalMaterialDelivered) TotalMaterialDelivered,
shiftseq
FROM Material 
WHERE shiftseq <> '999999'
AND shiftseq <= datediff(minute,ShiftStartDateTime,dateadd(hour,-7,getutcdate()))
GROUP BY shiftflag, siteflag, TruckId, shiftseq, ShiftStartDateTime)

SELECT
shiftflag,
siteflag,
TruckId AS Equipment,
TotalMaterialDelivered,
dateadd(hour,shiftseq,ShiftStartDateTime) as TimeinHour
FROM Final
WHERE TruckId IS NOT NULL
--AND TruckID = 'C101'

