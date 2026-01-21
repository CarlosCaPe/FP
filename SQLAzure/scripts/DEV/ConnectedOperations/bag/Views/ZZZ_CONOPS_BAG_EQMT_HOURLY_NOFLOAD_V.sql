CREATE VIEW [bag].[ZZZ_CONOPS_BAG_EQMT_HOURLY_NOFLOAD_V] AS



--SELECT * FROM [bag].[CONOPS_BAG_EQMT_HOURLY_NOFLOAD_V] WHERE shiftflag = 'prev'

CREATE VIEW [bag].[ZZZ_CONOPS_BAG_EQMT_HOURLY_NOFLOAD_V]
AS


WITH CTE AS (
SELECT
shiftindex,
site_code,
excav AS Equipment,
count(*) AS NofLoad,
HOS,
timeload_ts AS LoadTime
FROM dbo.lh_load WITH (NOLOCK)
where site_code = 'BAG' 
GROUP BY shiftindex,excav,timeload_ts,site_code,HOS),

NofLoadTimeSeq AS (
SELECT 
shiftflag,
siteflag,
shiftid,
ShiftStartDateTime,
Equipment,
SUM(NofLoad) AS NofLoad,
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
SUM(NofLoad) AS NofLoad,
shiftseq
FROM NofLoadTimeSeq a
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
NofLoad,
dateadd(hour,shiftseq,ShiftStartDateTime) as TimeinHour
FROM Final 



