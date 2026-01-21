CREATE VIEW [TYR].[CONOPS_TYR_TONS_LINE_GRAPH_V] AS



--select * from [tyr].[CONOPS_TYR_TONS_LINE_GRAPH_V] where shiftflag = 'curr'

CREATE VIEW [TYR].[CONOPS_TYR_TONS_LINE_GRAPH_V]
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
FROM [tyr].[CONOPS_TYR_TONS_LINE_SEQ_V] )


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
          SUM(shovelshifttarget) AS shifttarget,
          SUM(ShovelTarget) AS [target]
   FROM [tyr].[CONOPS_TYR_SHOVEL_SHIFT_TARGET_V] (NOLOCK)
   GROUP BY shiftid
) c ON a.shiftid = c.shiftid
WHERE shiftseq <= datediff(minute,ShiftStartDateTime,dateadd(hour,current_utc_offset,getutcdate()))
--AND ShiftFlag = 'PREV'
--ORDER BY ShiftSeq







