CREATE VIEW [bag].[ZZZ_CONOPS_BAG_HOURLY_TONS_V] AS






CREATE VIEW [bag].[ZZZ_CONOPS_BAG_HOURLY_TONS_V]
AS


WITH CTE AS (
SELECT 
a.shiftflag,
a.siteflag,
a.shiftid,
a.shiftindex,
a.ShiftStartDateTime,
shovelid,
c.shiftdumptime,
c.[TotalMaterialMined] as tons,
CASE WHEN datediff(minute, a.ShiftStartDateTime,c.shiftdumptime) 
between b.starts and b.ends THEN b.seq ELSE '999999' END AS shiftseq
FROM [BAG].[CONOPS_BAG_SHIFT_INFO_V] a 
CROSS JOIN [dbo].[HOURLY_TIME_SEQ] b
LEFT JOIN [bag].[CONOPS_BAG_EQMT_SHOVEL_HOURLY_TOTALMATERIALMINED_DUMPTIME_V] c 
ON a.shiftid = c.shiftid)

SELECT 
shiftflag,
a.siteflag,
a.shiftid,
a.shiftindex,
a.ShiftStartDateTime,
shovelid,
sum(tons) TotalMaterialMined,
shiftseq
FROM CTE a
LEFT JOIN [BAG].[SHIFT_INFO] b ON a.shiftid = b.shiftid 
WHERE shiftseq <> '999999'
AND a.shiftseq <= datediff(minute,b.ShiftStartDateTime,dateadd(hour,-7,getutcdate()))
--AND shiftflag = 'curr'
--AND shovelid = 'S22' 

GROUP BY 
shiftflag,a.siteflag,a.shiftid,a.shiftindex,a.ShiftStartDateTime,shovelid,shiftseq
--order by shiftseq


