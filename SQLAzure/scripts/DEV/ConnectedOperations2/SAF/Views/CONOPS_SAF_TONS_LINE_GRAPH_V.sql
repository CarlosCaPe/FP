CREATE VIEW [SAF].[CONOPS_SAF_TONS_LINE_GRAPH_V] AS










--select * from [saf].[CONOPS_SAF_TONS_LINE_GRAPH_V] where shiftflag = 'prev'

CREATE VIEW [saf].[CONOPS_SAF_TONS_LINE_GRAPH_V]
AS

WITH CTE AS (
SELECT
SiteFlag,
ShiftFlag,
shiftid,
ShiftStartDateTime,
SHIFTENDDATETIME,
current_utc_offset,
TotalMaterialMined,
TotalMaterialMoved,
Mill,
ROM,
Waste,
CrushLeach,
ShiftSeq
FROM [saf].[CONOPS_SAF_TONS_LINE_SEQ_V] )


SELECT
Siteflag,
Shiftflag,
ShiftStartDateTime,
SHIFTENDDATETIME,
TotalMaterialMined AS Actual,
TotalMaterialMoved,
Mill,
ROM,
Waste,
CrushLeach,
shifttarget,
[target],
ShiftSeq,
dateadd(minute,shiftseq,ShiftStartDateTime) as [DateTime]
FROm CTE a
LEFT JOIN (
   SELECT shiftid,
          shifttarget,
          targetvalue AS [target]
   FROM [saf].[CONOPS_SAF_SHIFT_TARGET_V] (NOLOCK)
) c ON a.shiftid = c.shiftid
WHERE shiftseq <= datediff(minute,ShiftStartDateTime,dateadd(hour,current_utc_offset,getutcdate()))
--AND ShiftFlag = 'PREV'
--ORDER BY ShiftSeq






