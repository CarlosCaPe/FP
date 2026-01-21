CREATE VIEW [mor].[CONOPS_MOR_SHIFT_CHANGE_V] AS

--select * from [mor].[CONOPS_MOR_SHIFT_CHANGE_V]

CREATE VIEW [mor].[CONOPS_MOR_SHIFT_CHANGE_V]
AS

SELECT 
shiftinfo.siteflag,
shiftinfo.shiftflag,
shiftinfo.shiftid,
scd.duration
FROM [dbo].[SHIFT_INFO_V] shiftinfo
LEFT JOIN (

SELECT
sc.site_code,
concat(right(replace(cast(sc.shiftdate as varchar),'-',''),6),'00',sc.shift_code) as shiftid,
sum(sc.duration)/60000 as duration
FROM (
SELECT 
a.shiftdate,
c.shift_code,
a.site_code,
sum(a.duration) as duration,
a.status,
a.category,
b.name
FROM [dbo].[status_event] a 
LEFT JOIN [dbo].[enum] b
ON a.category = b.num
LEFT JOIN [dbo].[shift_date] c
on a.shiftindex = c.shiftindex
WHERE a.site_code = 'MOR'
--AND a.shiftdate = '2022-11-25'
AND b.num = 9
AND b.enumname = 'TIMECAT'
GROUP BY a.shiftdate,a.site_code,a.status,a.category,b.name,c.shift_code) sc
GROUP BY sc.shiftdate,sc.shift_code,sc.site_code
) scd
ON shiftinfo.shiftid = scd.shiftid
WHERE shiftinfo.siteflag = 'MOR'

