CREATE VIEW [chi].[ZZZ_CONOPS_CHI_EQMT_TRUCK_HOURLY_TOTALMATERIALDELIVERED_V_OLD] AS






--select * from [chi].[CONOPS_CHI_EQMT_TRUCK_HOURLY_TOTALMATERIALDELIVERED_V]
CREATE VIEW [chi].[CONOPS_CHI_EQMT_TRUCK_HOURLY_TOTALMATERIALDELIVERED_V_OLD]
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
CONCAT(LEFT(SHIFTSTARTDATETIME,10),' ',RIGHT('00'+ CAST((DATEPART(HOUR, shiftdumptime)) AS VARCHAR(2)) ,2),':00:00.000') AS TimeinHour
FROM CHI.CONOPS_CHI_SHIFT_INFO_V a
LEFT JOIN Material b ON a.shiftid = b.shiftid
GROUP BY DATEPART(HOUR, shiftdumptime),TruckId,shiftflag,siteflag,SHIFTSTARTDATETIME


