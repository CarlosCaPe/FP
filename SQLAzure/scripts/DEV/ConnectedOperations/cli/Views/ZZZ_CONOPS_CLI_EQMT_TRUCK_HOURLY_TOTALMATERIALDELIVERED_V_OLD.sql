CREATE VIEW [cli].[ZZZ_CONOPS_CLI_EQMT_TRUCK_HOURLY_TOTALMATERIALDELIVERED_V_OLD] AS





--select * from [cli].[CONOPS_CLI_EQMT_TRUCK_HOURLY_TOTALMATERIALDELIVERED_V]
CREATE VIEW [cli].[CONOPS_CLI_EQMT_TRUCK_HOURLY_TOTALMATERIALDELIVERED_V_OLD]
AS


WITH CTE AS (
SELECT  
dumps.shiftid,
t.FieldId AS [TruckId],
dumps.FieldLsizetons AS [Tons],
dateadd(second,dumps.fieldtimedump,sinfo.shiftstartdatetime) as shiftdumptime
FROM [cli].SHIFT_DUMP dumps  WITH (NOLOCK)
LEFT JOIN [cli].Enum enums WITH (NOLOCK) on enums.Id=dumps.FieldLoad 
LEFT JOIN [cli].shift_loc loc WITH (NOLOCK) ON loc.Id = dumps.FieldLoc 
LEFT JOIN [cli].shift_eqmt t ON t.Id = dumps.FieldTruck
LEFT JOIN (
SELECT shiftid, ShiftStartDateTime,LEAD(ShiftStartDateTime) 
OVER ( ORDER BY shiftid ) AS ShiftEndDateTime 
from [cli].[shift_info]) sinfo ON dumps.shiftid = sinfo.shiftid
WHERE enums.Idx NOT IN (26,27,28,29,30)
AND (loc.FieldId IN ('CRUSHER 1'))),

Material AS (
SELECT
shiftid,
TruckId,
SUM(Tons) AS TotalMaterialDelivered,
COUNT(Tons)AS NumberofDumps,
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
FROM CLI.CONOPS_CLI_SHIFT_INFO_V a
LEFT JOIN Material b ON a.shiftid = b.shiftid
GROUP BY DATEPART(HOUR, shiftdumptime),TruckId,shiftflag,siteflag,SHIFTSTARTDATETIME


