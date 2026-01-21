CREATE VIEW [bag].[ZZZ_CONOPS_BAG_SHIFT_INFO_V_OLD] AS




--select * from [bag].[CONOPS_BAG_SHIFT_INFO_V]

CREATE VIEW [bag].[CONOPS_BAG_SHIFT_INFO_V_OLD] WITH SCHEMABINDING 
AS

SELECT 
a.siteflag,
a.shiftflag,
a.shiftid,
CASE WHEN b.ShiftStartDateTime IS NULL THEN
(CASE WHEN right(a.shiftid,1) = 1 THEN concat(cast(left(a.shiftid,6) as date),' 07:00:00.000')
ELSE concat(cast(left(a.shiftid,6) as date),' 19:00:00.000') END)
ELSE b.ShiftStartDateTime END AS ShiftStartDateTime,


CASE WHEN b.ShiftEndDateTime IS NULL THEN 
(CASE WHEN right(a.shiftid,1) = 1 THEN concat(cast(left(a.shiftid,6) as date),' 19:00:00.000')
ELSE concat(dateadd(day,1,cast(left(a.shiftid,6) as date)),' 07:00:00.000') END)
ELSE b.ShiftEndDateTime END AS ShiftEndDateTime,

COALESCE(b.ShiftDuration, 0) [ShiftDuration]

FROM 
(
SELECT
siteflag,
'PREV' as shiftflag, 
max(prevshiftid) as shiftid
from  [bag].[shift_info] with (nolock)
GROUP BY siteflag

union
select 
siteflag,
'CURR' as shiftflag, 
max(shiftid) as shiftid 
from  [bag].[shift_info] (nolock)
GROUP BY siteflag

union
select 
siteflag,
'NEXT' as shiftflag, 

CASE WHEN (select nextshiftid from (
SELECT  top 1 nextshiftid,
ROW_NUMBER() OVER(PARTITION BY shiftid ORDER BY shiftid desc) AS row_num
from [bag].[shift_info] (nolock)
order by shiftid desc) as nextshiftid) IS NULL

THEN (CASE WHEN RIGHT(max(shiftid),1) = 2 THEN 
right(concat(replace(cast(dateadd(day,1,cast(LEFT(max(shiftid),6) as date)) as varchar(10)),'-',''),'001'),9) 
ELSE right(concat(replace(cast(dateadd(day,1,cast(LEFT(max(shiftid),6) as date)) as varchar(10)),'-',''),'002'),9) END)

ELSE max(nextshiftid)
END AS shiftid
from  [bag].[shift_info] (nolock)
GROUP BY siteflag) a
LEFT JOIN (
SELECT shiftid, ShiftStartDateTime,LEAD(ShiftStartDateTime) OVER ( ORDER BY shiftid ) AS ShiftEndDateTime, ShiftDuration 
from [bag].[shift_info] (nolock)) b
on a.shiftid = b.shiftid

