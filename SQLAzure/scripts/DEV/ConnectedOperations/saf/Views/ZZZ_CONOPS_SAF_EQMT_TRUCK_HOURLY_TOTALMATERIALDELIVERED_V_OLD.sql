CREATE VIEW [saf].[ZZZ_CONOPS_SAF_EQMT_TRUCK_HOURLY_TOTALMATERIALDELIVERED_V_OLD] AS





--select * from [saf].[CONOPS_SAF_EQMT_TRUCK_HOURLY_TOTALMATERIALDELIVERED_V]
CREATE VIEW [saf].[CONOPS_SAF_EQMT_TRUCK_HOURLY_TOTALMATERIALDELIVERED_V_OLD]
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
FROM SAF.CONOPS_SAF_SHIFT_INFO_V a
LEFT JOIN Material b ON a.shiftid = b.shiftid
GROUP BY DATEPART(HOUR, shiftdumptime),TruckId,shiftflag,siteflag,SHIFTSTARTDATETIME


