CREATE VIEW [bag].[ZZZ_CONOPS_BAG_EQMT_TRUCK_HOURLY_PAYLOAD_V_OLD] AS









--SELECT * FROM [bag].[CONOPS_BAG_EQMT_TRUCK_HOURLY_PAYLOAD_V] WHERE shiftflag = 'curr'

CREATE VIEW [bag].[CONOPS_BAG_EQMT_TRUCK_HOURLY_PAYLOAD_V_OLD]
AS


WITH CTE AS (
SELECT
shiftindex,
site_code,
truck AS Equipment,
avg(measureton) as payload,
timeload_ts AS LoadTime
FROM dbo.lh_load WITH (NOLOCK)
where site_code = 'BAG' 
AND measureton > 200
GROUP BY shiftindex,truck,timeload_ts,site_code),

PayloadTimeSeq AS (
SELECT 
shiftflag,
siteflag,
shiftid,
ShiftStartDateTime,
Equipment,
AVG(payload) AS Payload,
CASE WHEN datediff(minute, a.ShiftStartDateTime,c.LoadTime) 
between b.starts and b.ends THEN b.seq ELSE '999999' END AS shiftseq
FROM [BAG].[CONOPS_BAG_SHIFT_INFO_V] a 
CROSS JOIN [dbo].[HOURLY_TIME_SEQ] b
LEFT JOIN CTE c 
ON a.shiftindex = c.shiftindex
GROUP BY 
shiftflag,siteflag,shiftid,Equipment,a.ShiftStartDateTime,c.LoadTime,b.starts,b.ends,b.seq),

Final AS (
SELECT
shiftflag,
a.siteflag,
a.ShiftStartDateTime,
Equipment,
AVG(Payload) Payload,
shiftseq
FROM PayloadTimeSeq a
LEFT JOIN [BAG].[SHIFT_INFO] b ON a.shiftid = b.shiftid 
WHERE shiftseq <> '999999'
AND a.shiftseq <= datediff(minute,b.ShiftStartDateTime,dateadd(hour,-7,getutcdate()))
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



