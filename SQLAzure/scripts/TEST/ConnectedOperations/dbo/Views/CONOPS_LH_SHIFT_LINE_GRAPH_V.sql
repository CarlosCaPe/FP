CREATE VIEW [dbo].[CONOPS_LH_SHIFT_LINE_GRAPH_V] AS





--SELECT * FROM [dbo].[CONOPS_LH_SHIFT_LINE_GRAPH_V] where shiftflag = 'curr' order by shiftseq asc

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
FROM [saf].[CONOPS_SAF_SHIFT_LINE_GRAPH_V]
WHERE siteflag = 'SAF'



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
FROM [sie].[CONOPS_SIE_SHIFT_LINE_GRAPH_V]
WHERE siteflag = 'SIE'


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
FROM [cli].[CONOPS_CLI_SHIFT_LINE_GRAPH_V]
WHERE siteflag = 'CMX'

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
FROM [chi].[CONOPS_CHI_SHIFT_LINE_GRAPH_V]
WHERE siteflag = 'CHI'


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
FROM [cer].[CONOPS_CER_SHIFT_LINE_GRAPH_V]
WHERE siteflag = 'CER'

