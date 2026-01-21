CREATE VIEW [mor].[ZZZ_CONOPS_MOR_EFH_V_NEW] AS


--select * from [mor].[CONOPS_MOR_EFH_V]
CREATE VIEW [mor].[CONOPS_MOR_EFH_V_NEW]
AS

SELECT 
a.shiftflag,
a.siteflag,
a.shiftid,
a.ShiftStartDateTime,
a.ShiftEndDateTime,
b.currenttime,
b.EFH,
b.EFHTarget,
b.EFHShiftTarget,
b.EFHSeq
FROM dbo.shift_info_v a

LEFT JOIN (
SELECT 
shiftid,
currenttime,
EFH,
EFHTarget,
EFHShiftTarget,
EFHSeq,
ROW_NUMBER() OVER (PARTITION BY shiftid,EFHSeq ORDER BY currenttime DESC) num
FROM [mor].[EFH_SNAPSHOT_SEQ] WITH (NOLOCK) ) b
ON a.shiftid = b.shiftid

WHERE a.siteflag = 'MOR'
AND b.num = 1

