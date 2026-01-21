CREATE VIEW [SIE].[CONOPS_SIE_SHIFT_SNAPSHOT_V] AS


CREATE VIEW [sie].[CONOPS_SIE_SHIFT_SNAPSHOT_V]
AS

WITH CTE AS (
SELECT 
sd.shiftid,
dateadd(second,sd.fieldtimedump,sinfo.shiftstartdatetime) as shiftdumptime ,
COUNT(t.FieldSize) AS [NrDumps] ,
s.FieldId AS [ShovelId],
sum(t.FieldSize) AS TotalMaterialMoved
FROM sie.shift_dump sd WITH (NOLOCK)
LEFT JOIN sie.shift_eqmt t WITH (NOLOCK)
ON t.Id = sd.FieldTruck AND t.SHIFTID = sd.shiftid
LEFT JOIN sie.shift_eqmt s WITH (NOLOCK)
ON s.Id = sd.FieldExcav AND s.SHIFTID = sd.shiftid
LEFT JOIN sie.shift_loc sl WITH (NOLOCK)
ON sl.Id = sd.FieldBlast AND sl.SHIFTID = sd.shiftid
LEFT JOIN sie.shift_loc sr WITH (NOLOCK)
ON sr.Id = sl.FieldRegion AND sr.SHIFTID = sd.shiftid
LEFT JOIN sie.shift_loc ssloc WITH (NOLOCK)
ON ssloc.Id = sd.FieldLoc AND ssloc.SHIFTID = sd.shiftid
LEFT JOIN sie.enum enum 
ON sd.FieldLoad = enum.enumtypeid and enum.ABBREVIATION = 'load'
LEFT JOIN (
SELECT shiftid, ShiftStartDateTime,LEAD(ShiftStartDateTime) 
OVER ( ORDER BY shiftid ) AS ShiftEndDateTime 
from [mor].[shift_info]) sinfo 
ON sd.shiftid = sinfo.shiftid 
GROUP BY sd.shiftid,s.FieldId,ssloc.FieldId,sl.FieldId,sd.fieldtimedump,sinfo.shiftstartdatetime)


SELECT  
shiftid,
shiftdumptime,
ISNULL(SUM(NrDumps), 0) AS [NrOfDumps] ,
ShovelId AS ShovelId, 
ISNULL(SUM(TotalMaterialMoved), 0) AS TotalMaterialMoved
FROM CTE 
GROUP BY ShovelId, shiftid,shiftdumptime



