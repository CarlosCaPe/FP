CREATE VIEW [SAF].[CONOPS_SAF_EQMT_TRUCK_HOURLY_PAYLOAD_V] AS




  
  
  
  
  
  
  
  
  
  
--SELECT * FROM [saf].[CONOPS_SAF_EQMT_TRUCK_HOURLY_PAYLOAD_V] WHERE shiftflag = 'curr'  
  
CREATE VIEW [saf].[CONOPS_SAF_EQMT_TRUCK_HOURLY_PAYLOAD_V]  
AS  
  
  
WITH CTE AS (  
SELECT  
shiftindex,  
site_code,  
truck AS Equipment,  
avg(measureton) as payload,  
timeload_ts AS LoadTime  
FROM dbo.lh_load WITH (NOLOCK)  
where site_code = 'SAF'   
AND measureton >= (SELECT PayloadFilterLower FROM dbo.PAYLOAD_FILTER WHERE SITEFLAG = 'SAF')
GROUP BY shiftindex,truck,timeload_ts,site_code),  
  
PayloadTimeSeq AS (  
SELECT   
shiftflag,  
siteflag,  
shiftid,  
ShiftStartDateTime,  
Equipment,  
AVG(payload) AS Payload,
a.current_utc_offset,
CASE WHEN datediff(minute, a.ShiftStartDateTime,c.LoadTime)   
between b.starts and b.ends THEN b.seq ELSE '999999' END AS shiftseq  
FROM [saf].[CONOPS_SAF_SHIFT_INFO_V] a   
CROSS JOIN [dbo].[HOURLY_TIME_SEQ] b WITH (NOLOCK)  
LEFT JOIN CTE c   
ON a.shiftindex = c.shiftindex  
GROUP BY   
shiftflag,siteflag,shiftid,Equipment,a.ShiftStartDateTime,a.current_utc_offset,c.LoadTime,b.starts,b.ends,b.seq),  
  
Final AS (  
SELECT  
shiftflag,  
a.siteflag,  
a.ShiftStartDateTime,  
Equipment,  
AVG(Payload) Payload,  
shiftseq  
FROM PayloadTimeSeq a  
LEFT JOIN [saf].[SHIFT_INFO] b WITH (NOLOCK) ON a.shiftid = b.shiftid   
WHERE shiftseq <> '999999'  
AND a.shiftseq <= datediff(minute,b.ShiftStartDateTime,dateadd(hour,a.current_utc_offset,getutcdate())) 
--AND shiftflag = 'prev'  
--AND Equipment = 'T219'   
  
GROUP BY   
shiftflag,a.siteflag,Equipment,shiftseq,a.ShiftStartDateTime  
--order by shiftseq  
)  
  
SELECT   
shiftflag,  
siteflag,  
Equipment,  
Payload,  
dateadd(hour,shiftseq,ShiftStartDateTime) as TimeinHour  
FROM Final   
  
  
  
  




