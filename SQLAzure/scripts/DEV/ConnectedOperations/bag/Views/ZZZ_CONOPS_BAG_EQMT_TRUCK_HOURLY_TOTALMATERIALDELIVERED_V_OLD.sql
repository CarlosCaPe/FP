CREATE VIEW [bag].[ZZZ_CONOPS_BAG_EQMT_TRUCK_HOURLY_TOTALMATERIALDELIVERED_V_OLD] AS



--select * from [bag].[CONOPS_BAG_EQMT_TRUCK_HOURLY_TOTALMATERIALDELIVERED_V]
CREATE VIEW [bag].[CONOPS_BAG_EQMT_TRUCK_HOURLY_TOTALMATERIALDELIVERED_V_OLD]
AS

WITH CTE AS (
SELECT  
dumps.shiftid,
sse.FieldId AS [TruckId],
dumps.FieldLsizetons AS [Tons],
dateadd(second,dumps.fieldtimedump,sinfo.shiftstartdatetime) as shiftdumptime
FROM [bag].SHIFT_DUMP_v dumps  WITH (NOLOCK)
LEFT JOIN [bag].shift_eqmt SSE ON SSE.id = dumps.FieldTruck AND SSE.ShiftId=dumps.ShiftId
LEFT JOIN [bag].Enum enums WITH (NOLOCK) on enums.Id=dumps.FieldLoad 
LEFT JOIN [bag].shift_loc loc WITH (NOLOCK) ON loc.Id = dumps.FieldLoc 
LEFT JOIN (
SELECT shiftid, ShiftStartDateTime,LEAD(ShiftStartDateTime) 
OVER ( ORDER BY shiftid ) AS ShiftEndDateTime 
from [bag].[shift_info]) sinfo ON dumps.shiftid = sinfo.shiftid
WHERE enums.Idx NOT IN (26,27,28,29,30)
AND (loc.FieldId in ('Crusher 2')
OR loc.FieldId LIKE 'SMALL CR%')),


Material AS (
SELECT
shiftflag,
siteflag,
ShiftStartDateTime,
TruckId,
SUM(Tons) AS TotalMaterialDelivered,
CASE WHEN datediff(minute, a.ShiftStartDateTime,c.shiftdumptime) 
between b.starts and b.ends THEN b.seq ELSE '999999' END AS shiftseq
FROM [bag].[CONOPS_BAG_SHIFT_INFO_V] a 
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

