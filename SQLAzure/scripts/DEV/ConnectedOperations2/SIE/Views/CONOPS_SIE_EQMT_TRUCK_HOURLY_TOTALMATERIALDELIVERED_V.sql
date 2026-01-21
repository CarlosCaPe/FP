CREATE VIEW [SIE].[CONOPS_SIE_EQMT_TRUCK_HOURLY_TOTALMATERIALDELIVERED_V] AS



  
  
  
  
--select * from [sie].[CONOPS_SIE_EQMT_TRUCK_HOURLY_TOTALMATERIALDELIVERED_V] order by shiftseq  
CREATE VIEW [sie].[CONOPS_SIE_EQMT_TRUCK_HOURLY_TOTALMATERIALDELIVERED_V]  
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
b.truckid,  
b.TotalMaterialDelivered,  
datediff(minute, a.ShiftStartDateTime,dateadd(hour,a.current_utc_offset,b.utc_created_date)) TimeDiff  
FROM [sie].[CONOPS_SIE_SHIFT_INFO_V] a   
LEFT JOIN [dbo].[Material_Delivered] b WITH (NOLOCK)  
ON a.shiftid = b.shiftid AND b.siteflag = 'SIE'  
  
),  
  
TimeSeq AS (  
SELECT   
shiftflag,  
siteflag,  
shiftid,  
ShiftStartDateTime,  
SHIFTENDDATETIME,
current_utc_offset,  
--LoadTime,  
CASE WHEN LoadTime IS NULL THEN NULL ELSE   
CAST(CONCAT(CAST(LoadTime AS DATE),' ',LEFT(CAST(LoadTime AS TIME),5),':00.000') AS DATETIME) END AS LoadTime,  
truckid,  
TotalMaterialDelivered,  
CASE WHEN TimeDiff between b.starts and b.ends THEN b.seq   
ELSE '999999' END AS shiftseq  
FROM CTE a  
CROSS JOIN [dbo].[HOURLY_TIME_SEQ] b WITH (NOLOCK)),  
  
  
TonsSeq AS (  
SELECT   
shiftflag,  
siteflag,  
shiftid,  
ShiftStartDateTime,  
SHIFTENDDATETIME,
current_utc_offset,  
truckid,  
TotalMaterialDelivered,  
LoadTime,  
shiftseq  
FROM TimeSeq   
WHERE shiftseq <> '999999'  
AND shiftseq <= datediff(hour,ShiftStartDateTime,dateadd(hour,current_utc_offset,getutcdate()))  
),  
  
Final AS (  
SELECT  
shiftflag,  
siteflag,  
shiftid,  
ShiftStartDateTime,  
SHIFTENDDATETIME,
current_utc_offset,  
truckid,  
TotalMaterialDelivered,  
shiftseq,  
LoadTime,  
ROW_NUMBER() OVER (PARTITION BY shiftid,truckid,shiftseq ORDER BY LoadTime DESC) num  
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
current_utc_offset,  
truckid,  
TotalMaterialDelivered,  
shiftseq  
FROM Final  
WHERE num = 1  
),  
  
FinalTotal AS (  
SELECT  
Siteflag,  
Shiftflag,  
ShiftStartDateTime,  
SHIFTENDDATETIME,
current_utc_offset,  
truckid AS Equipment,  
TotalMaterialDelivered AS OrigTotalMaterialDelivered,  
ISNULL(LAG(TotalMaterialDelivered, 1) OVER(PARTITION BY shiftflag,truckid ORDER BY shiftseq ASC),0) AS NewTotalMaterialDelivered,  
ShiftSeq,  
dateadd(hour,(shiftseq-1),ShiftStartDateTime) as TimeinHour  
FROm FinalSeq   
WHERE shiftseq <= datediff(hour,ShiftStartDateTime,dateadd(hour,current_utc_offset,getutcdate()))  
)  
  
SELECT  
siteflag,  
shiftflag,  
shiftstartdatetime,  
SHIFTENDDATETIME,
current_utc_offset,  
equipment,  
ISNULL((OrigTotalMaterialDelivered - NewTotalMaterialDelivered),0) TotalMaterialDelivered,  
TimeInHour,  
shiftseq  
FROM FinalTotal  
  
  
  



