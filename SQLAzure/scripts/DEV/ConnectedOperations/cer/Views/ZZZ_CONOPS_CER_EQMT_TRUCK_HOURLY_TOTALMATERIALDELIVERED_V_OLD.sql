CREATE VIEW [cer].[ZZZ_CONOPS_CER_EQMT_TRUCK_HOURLY_TOTALMATERIALDELIVERED_V_OLD] AS





--select * from [cer].[CONOPS_CER_EQMT_TRUCK_HOURLY_TOTALMATERIALDELIVERED_V]
CREATE VIEW [cer].[CONOPS_CER_EQMT_TRUCK_HOURLY_TOTALMATERIALDELIVERED_V_OLD]
AS

WITH CTE AS (
SELECT
dumps.shiftid,
sse.FieldId AS [TruckId],
dumps.FieldLsizetons  AS [Tons],
dateadd(second,dumps.fieldtimedump,sinfo.shiftstartdatetime) as shiftdumptime
FROM cer.shift_dump_v dumps WITH (NOLOCK)
LEFT JOIN cer.shift_loc s ON shift_loc_id = dumps.FieldLoc
LEFT JOIN cer.shift_eqmt SSE ON SSE.shift_eqmt_id = dumps.FieldTruck AND SSE.ShiftId=dumps.ShiftId
LEFT JOIN cer.Enum enums on enums.enum_Id=dumps.FieldLoad AND enums.Idx NOT IN (26,27,28,29,30)
LEFT JOIN (
SELECT shiftid, ShiftStartDateTime,LEAD(ShiftStartDateTime) 
OVER ( ORDER BY shiftid ) AS ShiftEndDateTime 
from cer.[shift_info]) sinfo ON dumps.shiftid = sinfo.shiftid
WHERE s.FieldId in ('MILLCHAN','MILLCRUSH1','MILLCRUSH2','HIDROCHAN')),

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
CONCAT(CAST(LEFT(SHIFTSTARTDATETIME,12) AS DATE),' ',RIGHT('00'+ CAST((DATEPART(HOUR, shiftdumptime)) AS VARCHAR(2)) ,2),':30:00.000') AS TimeinHour
FROM CER.CONOPS_CER_SHIFT_INFO_V a
LEFT JOIN Material b ON a.shiftid = b.shiftid
WHERE TruckId IS NOT NULL
GROUP BY DATEPART(HOUR, shiftdumptime),TruckId,shiftflag,siteflag,SHIFTSTARTDATETIME


