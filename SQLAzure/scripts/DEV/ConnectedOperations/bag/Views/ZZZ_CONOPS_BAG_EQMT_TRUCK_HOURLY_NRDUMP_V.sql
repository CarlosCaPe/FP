CREATE VIEW [bag].[ZZZ_CONOPS_BAG_EQMT_TRUCK_HOURLY_NRDUMP_V] AS



--SELECT * FROM [bag].[CONOPS_BAG_EQMT_TRUCK_HOURLY_NRDUMP_V] WHERE shiftflag = 'prev' and equipment = 'C101'

CREATE VIEW [bag].[ZZZ_CONOPS_BAG_EQMT_TRUCK_HOURLY_NRDUMP_V]
AS

WITH CTE AS (
SELECT
[sd].ShiftId,
[t].FieldId [TruckId],
COUNT([sd].FieldLsizetons) NumberofDumps,
dateadd(second,sd.fieldtimedump,si.shiftstartdatetime) as shiftdumptime 
FROM [bag].[shift_dump_v] [sd] WITH(NOLOCK)
LEFT JOIN [bag].[shift_eqmt] [t] WITH(NOLOCK)
ON [sd].FieldTruck = [t].id
LEFT JOIN (
SELECT shiftid, ShiftStartDateTime,LEAD(ShiftStartDateTime) 
OVER ( ORDER BY shiftid ) AS ShiftEndDateTime 
from [bag].[shift_info]) si ON sd.shiftid = si.shiftid
GROUP BY [sd].ShiftId, [t].FieldId, sd.fieldtimedump, si.shiftstartdatetime),

NrDumps AS (
SELECT
shiftflag,
siteflag,
ShiftStartDateTime,
TruckId,
shiftdumptime,
COUNT(NumberofDumps) NumberofDumps,
CASE WHEN datediff(minute, a.ShiftStartDateTime,c.shiftdumptime) 
between b.starts and b.ends THEN b.seq ELSE '999999' END AS shiftseq
FROM [bag].[CONOPS_BAG_SHIFT_INFO_V] a 
CROSS JOIN [dbo].[HOURLY_TIME_SEQ] b
LEFT JOIN CTE c
ON a.shiftid = c.shiftid
GROUP BY shiftflag, siteflag, ShiftStartDateTime, TruckId, shiftdumptime, b.starts, b.ends, b.seq
),

Final AS (
SELECT
shiftflag,
siteflag,
ShiftStartDateTime,
TruckId,
COUNT(NumberofDumps) NumberofDumps,
shiftseq
FROM NrDumps 
WHERE shiftseq <> '999999'
AND shiftseq <= datediff(minute,ShiftStartDateTime,dateadd(hour,-7,getutcdate()))
GROUP BY shiftflag, siteflag, TruckId, shiftseq, ShiftStartDateTime)

SELECT
shiftflag,
siteflag,
TruckId AS Equipment,
NumberofDumps,
dateadd(hour,shiftseq,ShiftStartDateTime) as TimeinHour
FROM Final
--WHERE shiftflag = 'PREV'
--AND TruckID = 'C101'

