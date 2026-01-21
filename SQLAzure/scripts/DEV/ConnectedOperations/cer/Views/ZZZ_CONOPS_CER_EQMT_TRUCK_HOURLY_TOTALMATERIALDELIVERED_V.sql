CREATE VIEW [cer].[ZZZ_CONOPS_CER_EQMT_TRUCK_HOURLY_TOTALMATERIALDELIVERED_V] AS



--select * from [cer].[CONOPS_CER_EQMT_TRUCK_HOURLY_TOTALMATERIALDELIVERED_V]
CREATE VIEW [cer].[zzz_CONOPS_CER_EQMT_TRUCK_HOURLY_TOTALMATERIALDELIVERED_V]
AS


WITH CTE AS (
SELECT 
a.shiftflag,
a.siteflag,
a.shiftid,
a.ShiftStartDateTime,
a.SHIFTENDDATETIME,
dateadd(hour,-5,b.utc_created_date) AS LoadTime,
b.truckid,
b.TotalMaterialDelivered,
datediff(minute, a.ShiftStartDateTime,dateadd(hour,-5,b.utc_created_date)) TimeDiff
FROM [cer].[CONOPS_CER_SHIFT_INFO_V] a 
LEFT JOIN [dbo].[Material_Delivered] b WITH (NOLOCK)
ON a.shiftid = b.shiftid AND b.siteflag = 'CVE'
--WHERE truckid = 'C354'
--AND a.shiftflag = 'CURR'
),

TimeSeq AS (
SELECT 
shiftflag,
siteflag,
shiftid,
ShiftStartDateTime,
SHIFTENDDATETIME,
--LoadTime,
CONVERT(DATETIME,CONVERT(VARCHAR(13),LoadTime,120)+ ':00') AS LoadTime,
truckid,
TotalMaterialDelivered,
CASE WHEN TimeDiff between b.starts and b.ends THEN b.seq 
ELSE '999999' END AS shiftseq
FROM CTE a
CROSS JOIN [dbo].[HOURLY_TIME_SEQ] b),


TonsSeq AS (
SELECT 
shiftflag,
siteflag,
shiftid,
ShiftStartDateTime,
SHIFTENDDATETIME,
truckid,
TotalMaterialDelivered,
LoadTime,
shiftseq
FROM TimeSeq 
WHERE shiftseq <> '999999'
AND shiftseq <= datediff(hour,ShiftStartDateTime,dateadd(hour,-5,getutcdate()))
),

Final AS (
SELECT
shiftflag,
siteflag,
shiftid,
ShiftStartDateTime,
SHIFTENDDATETIME,
truckid,
TotalMaterialDelivered,
shiftseq,
LoadTime,
ROW_NUMBER() OVER (PARTITION BY shiftid,LoadTime,truckid ORDER BY LoadTime DESC) num
FROM TonsSeq
WHERE shiftseq IS NOT NULL 
),

FinalSeq AS (
SELECT 
shiftflag,
siteflag,
shiftid,
ShiftStartDateTime,
SHIFTENDDATETIME,
truckid,
TotalMaterialDelivered,
shiftseq
FROM Final
WHERE num = 1
)

SELECT
Siteflag,
Shiftflag,
ShiftStartDateTime,
SHIFTENDDATETIME,
truckid AS Equipment,
SUM(TotalMaterialDelivered) AS TotalMaterialDelivered,
--TotalMaterialDelivered,
ShiftSeq,
dateadd(hour,shiftseq,ShiftStartDateTime) as TimeinHour
FROm FinalSeq 
WHERE shiftseq <= datediff(hour,ShiftStartDateTime,dateadd(hour,-5,getutcdate()))
GROUP BY Siteflag,Shiftflag,ShiftStartDateTime,SHIFTENDDATETIME,truckid,ShiftSeq




