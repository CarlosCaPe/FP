CREATE VIEW [CLI].[CONOPS_CLI_EQMT_SHOVEL_HOURLY_TOTALMATERIALMINED_V] AS
  
    
       
--select * from [cli].[CONOPS_CLI_EQMT_SHOVEL_HOURLY_TOTALMATERIALMINED_V] order by shiftseq        
CREATE VIEW [cli].[CONOPS_CLI_EQMT_SHOVEL_HOURLY_TOTALMATERIALMINED_V]        
AS        
        
WITH CTE AS (        
SELECT         
a.shiftflag,        
a.siteflag,        
a.shiftid,        
a.ShiftStartDateTime,        
a.SHIFTENDDATETIME,    
a.current_utc_offset,    
dateadd(hour,a.current_utc_offset,b.utc_created_date) AS LoadTime,        
b.ShovelId,        
b.TotalMaterialMined,        
b.TotalMaterialMoved,        
datediff(minute, a.ShiftStartDateTime,dateadd(hour,a.current_utc_offset,b.utc_created_date)) TimeDiff        
FROM [cli].[CONOPS_CLI_SHIFT_INFO_V] a         
LEFT JOIN [dbo].[Material_Mined] b WITH (NOLOCK)        
ON a.shiftid = b.shiftid AND b.siteflag = 'CMX'        
--WHERE ShovelId = 'T220'        
--AND a.shiftflag = 'PREV'        
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
ShovelId,        
TotalMaterialMined,        
TotalMaterialMoved,        
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
ShovelId,        
TotalMaterialMined,        
TotalMaterialMoved,        
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
ShovelId,        
TotalMaterialMined,        
TotalMaterialMoved,        
shiftseq,        
LoadTime,        
ROW_NUMBER() OVER (PARTITION BY shiftid,ShovelId,shiftseq ORDER BY LoadTime DESC) num        
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
ShovelId,        
TotalMaterialMined,        
TotalMaterialMoved,        
shiftseq        
FROM Final        
WHERE num = 1        
),        
        
FinalTotal AS (        
SELECT        
Siteflag,        
Shiftflag,        
shiftid,        
ShiftStartDateTime,        
SHIFTENDDATETIME,        
ShovelId AS Equipment,        
--TotalMaterialMined,        
TotalMaterialMined AS OrigTotalMaterialMined,        
ISNULL(LAG(TotalMaterialMined, 1) OVER(PARTITION BY shiftflag,ShovelId ORDER BY shiftseq ASC),0) AS NewTotalMaterialMined,        
TotalMaterialMoved AS OrigTotalMaterialMoved,        
ISNULL(LAG(TotalMaterialMoved, 1) OVER(PARTITION BY shiftflag,ShovelId ORDER BY shiftseq ASC),0) AS NewTotalMaterialMoved,        
ShiftSeq,        
dateadd(hour,shiftseq-1,ShiftStartDateTime) as TimeinHour        
FROm FinalSeq         
WHERE shiftseq <= datediff(hour,ShiftStartDateTime,dateadd(hour,current_utc_offset,getutcdate()))        
--AND shiftflag = 'prev' and ShovelId = 'T215'        
)        
        
SELECT        
siteflag,        
shiftflag,        
shiftid,        
shiftstartdatetime,        
shiftenddatetime,        
equipment,        
ISNULL((OrigTotalMaterialMined - NewTotalMaterialMined),0) TotalMaterialMined,        
ISNULL((OrigTotalMater