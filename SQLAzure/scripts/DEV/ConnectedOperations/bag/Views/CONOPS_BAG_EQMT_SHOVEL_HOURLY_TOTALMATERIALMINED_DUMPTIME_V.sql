CREATE VIEW [bag].[CONOPS_BAG_EQMT_SHOVEL_HOURLY_TOTALMATERIALMINED_DUMPTIME_V] AS
  
  
--select * from [bag].[CONOPS_BAG_EQMT_SHOVEL_HOURLY_TOTALMATERIALMINED_DUMPTIME_V]  
CREATE VIEW [bag].[CONOPS_BAG_EQMT_SHOVEL_HOURLY_TOTALMATERIALMINED_DUMPTIME_V]  
AS  
  
  
WITH ShiftDump AS (  
SELECT  
sd.shiftid,  
s.FieldId AS [ShovelId],  
dateadd(second,sd.fieldtimedump,sinfo.shiftstartdatetime) as shiftdumptime ,  
sd.FIELDLSIZETONS as FieldTons,  
sd.FIELDLOADREC,  
ssloc.FieldId AS [Location],  
sg.FieldId AS FieldGrade,  
enum.[description] AS [description]  
FROM bag.shift_dump sd WITH (NOLOCK)  
LEFT JOIN bag.shift_eqmt s WITH (NOLOCK)  
ON s.Id = sd.FieldExcav AND s.SHIFTID = sd.shiftid  
LEFT JOIN bag.SHIFT_GRADE sg WITH (NOLOCK)  
ON sd.FIELDGRADE = sg.Id AND sd.SHIFTID = sg.ShiftId  
LEFT JOIN bag.shift_loc ssloc WITH (NOLOCK)  
ON ssloc.Id = sd.FieldLoc AND ssloc.SHIFTID = sd.shiftid  
LEFT JOIN bag.enum enum WITH (NOLOCK)   
ON sd.FieldLoad = enum.id and enum.ABBREVIATION = 'load'   
LEFT JOIN (  
SELECT shiftid, ShiftStartDateTime,LEAD(ShiftStartDateTime)   
OVER ( ORDER BY shiftid ) AS ShiftEndDateTime   
from bag.[shift_info] WITH (NOLOCK)) sinfo ON sd.shiftid = sinfo.shiftid  
),  
  
CTE AS (  
SELECT    
shiftid,  
shiftdumptime,  
ShovelId,   
 (CASE WHEN Location LIKE '%INPIT%' THEN SUM(dumps.FieldTons) ELSE 0 END) AS Inpit, --  
 (CASE WHEN Location LIKE '%X' AND dumps.Description NOT LIKE '%OXD' THEN SUM(dumps.FieldTons) ELSE 0 END) AS MWastePlus,  
 (CASE WHEN Location NOT LIKE '%INPIT%' AND (dumps.FieldGrade NOT LIKE '%SX%' AND dumps.FieldGrade NOT LIKE '%LSP%')  
     AND FieldLoadRec IS NOT NULL THEN SUM(dumps.FieldTons) ELSE 0 END)  AS ExPit,   
 (CASE WHEN Location LIKE '%X' AND dumps.Description LIKE '%OXD' THEN SUM(dumps.FieldTons) ELSE 0 END) AS Oxide,  
 (CASE WHEN Location LIKE '%CRUSHER%' THEN SUM(dumps.FieldTons) ELSE 0 END) AS TDC,  
 (CASE WHEN Location LIKE '%W' THEN SUM(dumps.FieldTons) ELSE 0 END) AS Waste,  
 (CASE WHEN Location LIKE '%M' THEN SUM(dumps.FieldTons) ELSE 0 END) AS MWaste,  
 (CASE WHEN Location LIKE '%T' AND Location NOT LIKE '%INPIT%' THEN SUM(dumps.FieldTons) ELSE 0 END) AS TPWaste, --Tailings Project Waste  
 (CASE WHEN Location LIKE '%CRUSHER%' OR Location LIKE '%LSP%' OR Location LIKE '%SX STOCKPILE%' THEN SUM(dumps.FieldTons) ELSE 0 END) AS Ore,  
 (CASE WHEN (dumps.FieldGrade) LIKE '%SX%' OR (dumps.FieldGrade) LIKE '%LSP%' THEN SUM(dumps.FieldTons) ELSE 0 END) AS Rehandle  
FROm ShiftDump dumps   
GROUP BY ShovelId, Description, Location, FieldLoadRec, FieldGrade,shiftid,shiftdumptime)  
  
SELECT    
shiftid,  
ShovelId,   
shiftdumptime,  
NULLIF(SUM(INPIT) + SUM(EXPIT) + SUM(REHANDLE),0) AS TotalMaterialMined,  
NULLIF(SUM(Rehandle),0) AS TotalMaterialMoved  
FROM CTE   
GROUP BY ShovelId,shiftid,shiftdumptime  
  
  
  
  
  
