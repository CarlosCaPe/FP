CREATE VIEW [mor].[ZZZ_CONOPS_MOR_EQMT_TRUCK_HOURLY_TOTALMATERIALDELIVERED_V_OLD] AS





--select * from [mor].[CONOPS_MOR_EQMT_TRUCK_HOURLY_TOTALMATERIALDELIVERED_V]
CREATE VIEW [mor].[CONOPS_MOR_EQMT_TRUCK_HOURLY_TOTALMATERIALDELIVERED_V_OLD]
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
shiftid,
TruckId,
SUM(Tons) AS TotalMaterialDelivered,
COUNT(Tons) AS NumberofDumps,
shiftdumptime
FROM CTE
GROUP BY shiftid, truckid,shiftdumptime)

SELECT 
shiftflag,
siteflag,
TruckId,
SUM(TotalMaterialDelivered) AS TotalMaterialDelivered,
SUM(NumberofDumps) AS NumberofDumps,
CONCAT(LEFT(SHIFTSTARTDATETIME,10),' ',RIGHT('00'+ CAST((DATEPART(HOUR, shiftdumptime)) AS VARCHAR(2)) ,2),':15:00.000') AS TimeinHour
FROM MOR.CONOPS_MOR_SHIFT_INFO_V a
LEFT JOIN Material b ON a.shiftid = b.shiftid
GROUP BY DATEPART(HOUR, shiftdumptime),TruckId,shiftflag,siteflag,SHIFTSTARTDATETIME


