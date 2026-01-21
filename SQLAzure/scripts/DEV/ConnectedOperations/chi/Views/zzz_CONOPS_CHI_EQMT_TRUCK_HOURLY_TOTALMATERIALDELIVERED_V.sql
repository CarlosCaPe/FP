CREATE VIEW [chi].[zzz_CONOPS_CHI_EQMT_TRUCK_HOURLY_TOTALMATERIALDELIVERED_V] AS



--select * from [chi].[CONOPS_CHI_EQMT_TRUCK_HOURLY_TOTALMATERIALDELIVERED_V]
CREATE VIEW [chi].[zzz_CONOPS_CHI_EQMT_TRUCK_HOURLY_TOTALMATERIALDELIVERED_V]
AS

WITH CTE AS (
SELECT 
dumps.shiftid,
s.FieldId AS TruckId,
dumps.FieldLsizetons AS [Tons],
dateadd(second,dumps.fieldtimedump,sinfo.shiftstartdatetime) as shiftdumptime
FROM chi.shift_dump_v dumps WITH (NOLOCK)
LEFT JOIN chi.shift_eqmt s WITH (NOLOCK)  ON s.Id = dumps.FieldTruck AND s.SHIFTID = dumps.shiftid
LEFT JOIN chi.enum enums WITH (NOLOCK) ON enums.Id=dumps.FieldLoad
LEFT JOIN (
SELECT shiftid, ShiftStartDateTime,LEAD(ShiftStartDateTime) 
OVER ( ORDER BY shiftid ) AS ShiftEndDateTime 
from chi.[shift_info]) sinfo ON dumps.shiftid = sinfo.shiftid
WHERE enums.Idx NOT IN (2)),


Material AS (
SELECT
shiftflag,
siteflag,
ShiftStartDateTime,
TruckId,
SUM(Tons) AS TotalMaterialDelivered,
CASE WHEN datediff(minute, a.ShiftStartDateTime,c.shiftdumptime) 
between b.starts and b.ends THEN b.seq ELSE '999999' END AS shiftseq
FROM [chi].[CONOPS_CHI_SHIFT_INFO_V] a 
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

