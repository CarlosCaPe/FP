CREATE VIEW [dbo].[CONOPS_LH_EFH_V] AS


CREATE VIEW [dbo].[CONOPS_LH_EFH_V]
AS

SELECT 
shiftflag,
siteflag,
EFH,
EFHShiftTarget,
EFHTarget,
avgEFH,
ShiftStartDateTime,
ShiftEndDateTime,
breakbyhour
FROM [mor].[CONOPS_MOR_EFH_V] 
WHERE siteflag = 'MOR'

UNION ALL

SELECT 
shiftflag,
siteflag,
EFH,
EFHShiftTarget,
EFHTarget,
avgEFH,
ShiftStartDateTime,
ShiftEndDateTime,
breakbyhour
FROM [bag].[CONOPS_BAG_EFH_V] 
WHERE siteflag = 'BAG'




