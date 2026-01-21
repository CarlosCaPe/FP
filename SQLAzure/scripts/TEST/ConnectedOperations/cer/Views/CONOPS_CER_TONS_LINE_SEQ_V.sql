CREATE VIEW [cer].[CONOPS_CER_TONS_LINE_SEQ_V] AS


CREATE VIEW [cer].[CONOPS_CER_TONS_LINE_SEQ_V]
AS

WITH CTE AS (
SELECT 
a.shiftflag,
a.siteflag,
a.shiftid,
a.ShiftStartDateTime,
a.SHIFTENDDATETIME,
current_utc_offset,
dateadd(hour,a.current_utc_offset,b.utc_created_date) AS LoadTime,
b.shovelid,
b.[TotalMaterialMined],
b.TotalMaterialMoved,
b.Mill,
b.ROM,
b.Waste,
b.CrushLeach,
datediff(second, a.ShiftStartDateTime,dateadd(hour,a.current_utc_offset,b.utc_created_date)) TimeDiff
FROM [cer].[CONOPS_CER_SHIFT_INFO_V] a 
LEFT JOIN [dbo].[Shift_Line_Graph] b WITH (NOLOCK)
ON a.shiftid = b.shiftid AND b.siteflag = 'CVE'),

TimeSeq AS (
SELECT 
shiftflag,
siteflag,
shiftid,
ShiftStartDateTime,
SHIFTENDDATETIME,
current_utc_offset,
LoadTime,
--shovelid,
TotalMaterialMined,
TotalMaterialMoved,
Mill,
ROM,
Waste,
CrushLeach,
CASE WHEN TimeDiff between b.starts and b.ends THEN b.seq 
ELSE '999999' END AS shiftseq
FROM CTE a
CROSS JOIN [dbo].[TIME_SEQ] b WITH (NOLOCK)),


TonsSeq AS (
SELECT 
shiftflag,
siteflag,
shiftid,
ShiftStartDateTime,
SHIFTENDDATETIME,
current_utc_offset,
--shovelid,
sum(TotalMaterialMined) TotalMaterialMined,
SUM(TotalMaterialMoved) TotalMaterialMoved,
SUM(Mill) Mill,
SUM(ROM) ROM,
SUM(Waste) Waste,
SUM(CrushLeach) CrushLeach,
LoadTime,
shiftseq
FROM TimeSeq 
WHERE shiftseq <> '999999'
--AND shiftseq <= datediff(second,ShiftStartDateTime,dateadd(hour,current_utc_offset,getutcdate()))
GROUP BY shiftflag,siteflag,shiftid,ShiftStartDateTime,SHIFTENDDATETIME,
current_utc_offset,LoadTime,shiftseq),

TonsFinal AS (

SELECT 
shiftflag,
siteflag,
shiftid,
ShiftStartDateTime,
SHIFTENDDATETIME,
current_utc_offset,
--shovelid,
sum(TotalMaterialMined) TotalMaterialMined,
SUM(TotalMaterialMoved) TotalMaterialMoved,
SUM(Mill) Mill,
SUM(ROM) ROM,
SUM(Waste) Waste,
SUM(CrushLeach) CrushLeach,
LoadTime,
shiftseq
FROM TonsSeq
--WHERE shiftflag = 'prev'
GROUP BY shiftflag,siteflag,shiftid,ShiftStartDateTime,SHIFTENDDATETIME,
current_utc_offset,LoadTime,shiftseq

),

Final AS (
SELECT
shiftflag,
siteflag,
shiftid,
ShiftStartDateTime,
SHIFTENDDATETIME,
current_utc_offset,
SUM(TotalMaterialMined) TotalMaterialMined,
SUM(TotalMaterialMoved) TotalMaterialMoved,
SUM(Mill) Mill,
SUM(ROM) ROM,
SUM(Waste) Waste,
SUM(CrushLeach) CrushLeach,
--LoadTime,
shiftseq,
ROW_NUMBER() OVER (PARTITION BY shiftid,LoadTime ORDER BY LoadTime ASC) num
FROM TonsFinal
WHERE shiftseq IS NOT NULL 
--AND shiftflag = 'prev'
--AND shovelid = 'S12'
GROUP BY 
shiftflag,
siteflag,
shiftid,
ShiftStartDateTime,
SHIFTENDDATETIME,
current_utc_offset,
LoadTime,
shiftseq
--order by shiftseq
)

SELECT 
shiftflag,
siteflag,
shiftid,
ShiftStartDateTime,
SHIFTENDDATETIME,
current_utc_offset,
SUM(TotalMaterialMined) TotalMaterialMined,
SUM(TotalMaterialMoved) TotalMaterialMoved,
SUM(Mill) Mill,
SUM(ROM) ROM,
SUM(Waste) Waste,
SUM(CrushLeach) CrushLeach,
--LoadTime,
shiftseq
FROM Final
WHERE num = 1
GROUP BY 
shiftflag,
siteflag,
shiftid,
ShiftStartDateTime,
SHIFTENDDATETIME,
current_utc_offset,
shiftseq

