CREATE VIEW [dbo].[CONOPS_LH_EFH_V] AS





--select * from [dbo].[CONOPS_LH_EFH_V] where shiftflag = 'curr' order by deltac_ts asc
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
FROM [saf].[CONOPS_SAF_EFH_V] 
WHERE siteflag = 'SAF'



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
FROM [sie].[CONOPS_SIE_EFH_V] 
WHERE siteflag = 'SIE'


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
FROM [cli].[CONOPS_CLI_EFH_V] 
WHERE siteflag = 'CMX'

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
FROM [chi].[CONOPS_CHI_EFH_V] 
WHERE siteflag = 'CHI'

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
FROM [cer].[CONOPS_CER_EFH_V] 
WHERE siteflag = 'CER'

