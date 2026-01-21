CREATE VIEW [dbo].[CONOPS_LH_SHIFT_LINE_GRAPH_V] AS


CREATE VIEW [dbo].[CONOPS_LH_SHIFT_LINE_GRAPH_V]
AS

SELECT 
shiftflag,
siteflag,
shiftid,
dateadd(minute,shiftseq,ShiftStartDateTime) as [DateTime],
actual/1000.0 as actual,
[target]/1000.0 as [target],
shifttarget/1000.0 as shifttarget,
ShiftStartDateTime,
ShiftEndDateTime
FROM [mor].[CONOPS_MOR_SHIFT_LINE_GRAPH_V]
WHERE siteflag = 'MOR'

UNION ALL


SELECT 
shiftflag,
siteflag,
shiftid,
dateadd(minute,shiftseq,ShiftStartDateTime) as [DateTime],
actual/1000.0 as actual,
[target]/1000.0 as [target],
shifttarget/1000.0 as shifttarget,
ShiftStartDateTime,
ShiftEndDateTime
FROM [bag].[CONOPS_BAG_SHIFT_LINE_GRAPH_V]
WHERE siteflag = 'BAG'



