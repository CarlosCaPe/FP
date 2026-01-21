CREATE VIEW [TYR].[CONOPS_TYR_HOURLY_TOTALMATERIALMINED_V] AS



--select * from [tyr].[CONOPS_TYR_HOURLY_TOTALMATERIALMINED_V] order by shiftseq      
CREATE VIEW [TYR].[CONOPS_TYR_HOURLY_TOTALMATERIALMINED_V]      
AS      

WITH CTE AS (
SELECT 
a.shiftflag,
a.siteflag,
a.shiftid,
a.ShiftStartDateTime,
a.ShiftEndDateTime,
current_utc_offset,
dateadd(hour,a.current_utc_offset,b.utc_created_date) AS LoadTime,
b.TotalMaterialMined,
b.TotalMaterialMoved,
b.Mill,
b.ROM,
b.Waste,
b.CrushLeach,
datediff(minute, a.ShiftStartDateTime,dateadd(hour,a.current_utc_offset,b.utc_created_date)) TimeDiff
FROM [TYR].[CONOPS_TYR_SHIFT_INFO_V] a 
LEFT JOIN [dbo].[Shift_Line_Graph] b WITH (NOLOCK)
ON a.shiftid = b.shiftid AND b.siteflag = 'TYR'
),

TonsSum AS(
SELECT
shiftflag,
siteflag,
shiftid,
ShiftStartDateTime,
ShiftEndDateTime,
current_utc_offset,
LoadTime,
TimeDiff,
SUM(TotalMaterialMined) AS TotalMaterialMined,
SUM(TotalMaterialMoved) AS TotalMaterialMoved,  
SUM(Mill) AS Mill,
SUM(ROM) AS ROM,
SUM(Waste) AS Waste,
SUM(CrushLeach) AS CrushLeach
FROM CTE
GROUP BY 
shiftflag, siteflag, shiftid, ShiftStartDateTime, ShiftEndDateTime, current_utc_offset, LoadTime, TimeDiff
),

TimeSeq AS (
SELECT 
shiftflag,
siteflag,
shiftid,
ShiftStartDateTime,
ShiftEndDateTime,
current_utc_offset,
LoadTime,
TotalMaterialMined,
TotalMaterialMoved, 
Mill,
ROM,
Waste,
CrushLeach,
CASE WHEN TimeDiff between b.starts and b.ends THEN b.seq 
ELSE '999999' END AS shiftseq
FROM TonsSum a
CROSS JOIN [dbo].[HOURLY_TIME_SEQ] b WITH (NOLOCK)
),

TonsSeq AS (
SELECT 
shiftflag,
siteflag,
shiftid,
ShiftStartDateTime,
ShiftEndDateTime,
current_utc_offset,  
TotalMaterialMined,
TotalMaterialMoved,  
Mill,
ROM,
Waste,
CrushLeach,
LoadTime,
shiftseq -1 AS shiftseq,
ROW_NUMBER() OVER (PARTITION BY shiftid,shiftseq ORDER BY LoadTime DESC) num
FROM TimeSeq 
WHERE shiftseq <> '999999'
--AND shiftseq <= datediff(hour,ShiftStartDateTime,dateadd(hour,current_utc_offset,getutcdate()))
),

FinalSeq AS(
SELECT
shiftflag,
siteflag,
shiftid,
ShiftStartDateTime,
ShiftEndDateTime,
current_utc_offset,
dateadd(hour,shiftseq,ShiftStartDateTime) AS TimeInHour,
shiftseq,
TotalMaterialMined,
TotalMaterialMoved,  
Mill,
ROM,
Waste,
CrushLeach
FROM TonsSeq
WHERE num = 1
),

Final AS(
SELECT
shiftflag,
siteflag,
shiftid,
ShiftStartDateTime,
ShiftEndDateTime,
current_utc_offset,
TimeInHour,
shiftseq,
TotalMaterialMined,
ISNULL(LAG(TotalMaterialMined, 1) OVER(PARTITION BY shiftflag ORDER BY shiftseq ASC),0) AS LagTotalMaterialMined,
TotalMaterialMoved,
ISNULL(LAG(TotalMaterialMoved, 1) OVER(PARTITION BY shiftflag ORDER BY shiftseq ASC),0) AS LagTotalMaterialMoved,
Mill,
ISNULL(LAG(Mill, 1) OVER(PARTITION BY shiftflag ORDER BY shiftseq ASC),0) AS LagMill,
ROM,
ISNULL(LAG(ROM, 1) OVER(PARTITION BY shiftflag ORDER BY shiftseq ASC),0) AS LagROM,
Waste,
ISNULL(LAG(Waste, 1) OVER(PARTITION BY shiftflag ORDER BY shiftseq ASC),0) AS LagWaste,
CrushLeach,
ISNULL(LAG(CrushLeach, 1) OVER(PARTITION BY shiftflag ORDER BY shiftseq ASC),0) AS LagCrushLeach
FROM FinalSeq
),

FinalTons AS(
SELECT
shiftflag,
siteflag,
shiftid,
ShiftStartDateTime,
ShiftEndDateTime,
current_utc_offset,
TimeInHour,
shiftseq,
TotalMaterialMined - LagTotalMaterialMined AS TotalMaterialMined,
TotalMaterialMoved - LagTotalMaterialMoved AS TotalMaterialMoved,
Mill - LagMill AS Mill,
ROM - LagROM AS ROM,
Waste - LagWaste AS Waste,
CrushLeach - LagCrushLeach AS CrushLeach
FROM Final
)

SELECT
a.shiftflag,
siteflag,
shiftid,
ShiftStartDateTime,
ShiftEndDateTime,
current_utc_offset,
TimeInHour,
shiftseq,
TotalMaterialMined,
TotalMaterialMoved,  
Mill,
ROM,
Waste,
CrushLeach,
ISNULL(ShiftTarget,0) ShiftTarget,
ISNULL([Target],0) [Target]
FROM FinalTons a
LEFT JOIN (
   SELECT shiftflag,
          SUM(shovelshifttarget) AS shifttarget,
          SUM(shoveltarget) AS [target]
   FROM [TYR].[CONOPS_TYR_SHOVEL_SHIFT_TARGET_V] (NOLOCK)