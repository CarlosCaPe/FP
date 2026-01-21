CREATE VIEW [Arch].[CONOPS_ARCH_SHIFT_SNAPSHOT_V] AS



CREATE VIEW [Arch].[CONOPS_ARCH_SHIFT_SNAPSHOT_V]
AS


WITH ShiftDump AS (
SELECT
sd.shiftid,
dateadd(second,sd.fieldtimedump,sinfo.shiftstartdatetime) as shiftdumptime ,
s.FieldId AS [ShovelId],
sd.FIELDLSIZETONS as FieldTons,
sd.FIELDLOADREC,
ssloc.FieldId AS [Location],
sg.FieldId AS FieldGrade,
enum.[description] AS [description]
FROM ARCH.shift_dump sd WITH (NOLOCK)
LEFT JOIN ARCH.shift_eqmt s WITH (NOLOCK)
ON s.Id = sd.FieldExcav AND s.SHIFTID = sd.shiftid
LEFT JOIN ARCH.SHIFT_GRADE sg WITH (NOLOCK)
ON sd.FIELDGRADE = sg.Id AND sd.SHIFTID = sg.ShiftId
LEFT JOIN ARCH.shift_loc ssloc WITH (NOLOCK)
ON ssloc.Id = sd.FieldLoc AND ssloc.SHIFTID = sd.shiftid
LEFT JOIN ARCH.enum enum 
ON sd.FieldLoad = enum.id and enum.ABBREVIATION = 'load' 
LEFT JOIN (
SELECT shiftid, ShiftStartDateTime,LEAD(ShiftStartDateTime) 
OVER ( ORDER BY shiftid ) AS ShiftEndDateTime 
from [Arch].[shift_info]) sinfo ON sd.shiftid = sinfo.shiftid
),

CTE AS (
SELECT  shiftid,shiftdumptime,ShovelId, COUNT(dumps.FieldTons) AS NrDumps,
 (CASE WHEN Location LIKE '%INPIT%' THEN SUM(dumps.FieldTons) ELSE 0 END) AS Inpit, --
 (CASE WHEN Location NOT LIKE '%INPIT%' AND (dumps.FieldGrade NOT LIKE '%SX%' AND dumps.FieldGrade NOT LIKE '%LSP%')
     AND FieldLoadRec IS NOT NULL THEN SUM(dumps.FieldTons) ELSE 0 END)  AS ExPit, 
 (CASE WHEN (dumps.FieldGrade) LIKE '%SX%' OR (dumps.FieldGrade) LIKE '%LSP%' THEN SUM(dumps.FieldTons) ELSE 0 END) AS Rehandle
FROm ShiftDump dumps 
GROUP BY ShovelId, Description, Location, FieldLoadRec, FieldGrade,shiftid,shiftdumptime)

SELECT  
shiftid,
shiftdumptime,
ShovelId, 
NULLIF(CAST(SUM(NrDumps) AS INTEGER) , 0) AS NrOfDumps,
NULLIF(SUM(INPIT) + SUM(EXPIT) + SUM(REHANDLE),0) AS TotalMaterialMined
FROM CTE 
GROUP BY ShovelId,shiftid,shiftdumptime

