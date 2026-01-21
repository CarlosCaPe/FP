CREATE VIEW [saf].[zzz_CONOPS_SAF_EQMT_TRUCK_HOURLY_TOTALMATERIALDELIVERED_V] AS



--select * from [saf].[CONOPS_SAF_EQMT_TRUCK_HOURLY_TOTALMATERIALDELIVERED_V]
CREATE VIEW [saf].[zzz_CONOPS_SAF_EQMT_TRUCK_HOURLY_TOTALMATERIALDELIVERED_V]
AS

WITH CTE AS (
SELECT 
SSD.[ShiftId],
t.FieldId TruckId,
SSE.[FieldSize] AS Tons,
dateadd(second,SSD.fieldtimedump,sinfo.shiftstartdatetime) as shiftdumptime
FROM [saf].SHIFT_DUMP SSD  WITH (NOLOCK)
LEFT JOIN [saf].SHIFT_EQMT SSE  WITH (NOLOCK) ON SSE.Id = SSD.FieldTruck AND SSE.SHIFTID = SSD.SHIFTID
LEFT JOIN [saf].SHIFT_EQMT t  WITH (NOLOCK) ON t.Id = SSD.FieldTruck AND t.SHIFTID = SSD.SHIFTID
LEFT JOIN [saf].SHIFT_EQMT e  WITH (NOLOCK) ON e.Id = SSD.FieldExcav 
AND e.SHIFTID = SSD.SHIFTID AND e.FieldId NOT IN ('S003','S005')
LEFT JOIN saf.shift_loc l WITH (NOLOCK) ON l.Id = SSD.FieldLoc
LEFT JOIN saf.shift_loc r WITH (NOLOCK) ON r.Id = l.FieldRegion AND r.FieldId = 'SAN JUAN'
LEFT JOIN (
SELECT shiftid, ShiftStartDateTime,LEAD(ShiftStartDateTime) 
OVER ( ORDER BY shiftid ) AS ShiftEndDateTime 
from saf.[shift_info]) sinfo ON SSD.shiftid = sinfo.shiftid),


Material AS (
SELECT
shiftflag,
siteflag,
ShiftStartDateTime,
TruckId,
SUM(Tons) AS TotalMaterialDelivered,
CASE WHEN datediff(minute, a.ShiftStartDateTime,c.shiftdumptime) 
between b.starts and b.ends THEN b.seq ELSE '999999' END AS shiftseq
FROM [saf].[CONOPS_SAF_SHIFT_INFO_V] a 
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

