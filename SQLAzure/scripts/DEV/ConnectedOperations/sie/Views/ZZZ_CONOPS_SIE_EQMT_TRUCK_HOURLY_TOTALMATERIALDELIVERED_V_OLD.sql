CREATE VIEW [sie].[ZZZ_CONOPS_SIE_EQMT_TRUCK_HOURLY_TOTALMATERIALDELIVERED_V_OLD] AS





--select * from [sie].[CONOPS_SIE_EQMT_TRUCK_HOURLY_TOTALMATERIALDELIVERED_V]
CREATE VIEW [sie].[CONOPS_SIE_EQMT_TRUCK_HOURLY_TOTALMATERIALDELIVERED_V_OLD]
AS


WITH CTE AS (
SELECT  
dumps.shiftid,
t.FieldId AS [TruckId],
dumps.FieldLsizetons AS [Tons],
dateadd(second,dumps.fieldtimedump,sinfo.shiftstartdatetime) as shiftdumptime
FROM [sie].SHIFT_DUMP_V dumps  WITH (NOLOCK)
LEFT JOIN [sie].Enum enums WITH (NOLOCK) on enums.Id=dumps.FieldLoad 
LEFT JOIN [sie].shift_loc loc WITH (NOLOCK) ON loc.Id = dumps.FieldLoc 
LEFT JOIN [sie].shift_eqmt t ON t.Id = dumps.FieldTruck
LEFT JOIN (
SELECT shiftid, ShiftStartDateTime,LEAD(ShiftStartDateTime) 
OVER ( ORDER BY shiftid ) AS ShiftEndDateTime 
from [sie].[shift_info]) sinfo ON dumps.shiftid = sinfo.shiftid
WHERE enums.Idx NOT IN (26,27,28,29,30)
AND (loc.FieldId IN ('CR13909O', 'A-SIDE', 'B-SIDE'))),

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
FROM SIE.CONOPS_SIE_SHIFT_INFO_V a
LEFT JOIN Material b ON a.shiftid = b.shiftid
GROUP BY DATEPART(HOUR, shiftdumptime),TruckId,shiftflag,siteflag,SHIFTSTARTDATETIME


