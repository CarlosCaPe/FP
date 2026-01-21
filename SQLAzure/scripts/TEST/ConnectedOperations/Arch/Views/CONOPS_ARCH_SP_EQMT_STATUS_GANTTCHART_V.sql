CREATE VIEW [Arch].[CONOPS_ARCH_SP_EQMT_STATUS_GANTTCHART_V] AS


CREATE VIEW [Arch].[CONOPS_ARCH_SP_EQMT_STATUS_GANTTCHART_V]
AS


WITH SHIFTINFO AS(
SELECT 
a.siteflag,
a.shiftflag,
a.shiftid,
a.shiftindex,
b.ShiftStartDateTime,
b.ShiftEndDateTime
FROM [Arch].[CONOPS_ARCH_EQMT_SHIFT_INFO_V] a
LEFT JOIN (
SELECT 
siteflag,
shiftflag,
min(ShiftStartDateTime) AS ShiftStartDateTime,
max(ShiftEndDateTime) As ShiftEndDateTime
FROM [Arch].[CONOPS_ARCH_EQMT_SHIFT_INFO_V]
GROUP BY siteflag,shiftflag) b
ON a.shiftflag = b.shiftflag),

EVNTS AS (
select shiftid,eqmt,startdatetime,enddatetime,duration,reasonidx,reasons,[status]
from [Arch].[asset_efficiency] (NOLOCK)
where unittype = 'shovel'),

STAT AS (
SELECT
si.shiftid,
si.shiftflag,
si.shiftindex,
x.eqmt,
x.eqmtcurrstatus
FROM dbo.SHIFT_INFO_V si
LEFT JOIN (
select shiftid,eqmt,[status] as eqmtcurrstatus,
ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num
from [Arch].[asset_efficiency] (NOLOCK)
where unittype = 'shovel') x
ON si.shiftid = x.shiftid 
WHERE x.num = 1 
AND si.siteflag = '<SITECODE>'),

EFH AS (
select site_code,concat(concat(right(replace(cast(shiftdate as varchar(10)),'-',''),6),'00'),shift_code) as shiftid,
excav,
avg(distloaded + (fliftup * 27.1428) + (fliftdown * 16)) as EFH
FROM dbo.delta_c (NOLOCK)
--WHERE site_code = '<SITECODE>'
group by shiftdate,shift_code,site_code,excav),

TPRH AS (
SELECT
shiftindex,
site_code,
eqmt,
tprh 
FROM [Arch].[CONOPS_ARCH_SHOVEL_TPRH_V] (NOLOCK)
--WHERE site_code = '<SITECODE>'
)


SELECT
s.shiftflag,
s.siteflag,
s.shiftid,
s.ShiftStartDateTime,
s.ShiftEndDateTime,
e.eqmt,
e.startdatetime,
e.enddatetime,
e.duration,
e.reasonidx,
e.reasons,
e.[status],
st.eqmtcurrstatus,
efh.EFH,
tp.tprh
FROM SHIFTINFO s 
LEFT JOIN EVNTS e ON s.shiftid = e.shiftid 
LEFT JOIN STAT st ON s.shiftflag = st.shiftflag AND e.eqmt = st.eqmt
LEFT JOIn EFH efh ON efh.shiftid = st.shiftid AND efh.EXCAV = e.eqmt
LEFT JOIN TPRH tp ON tp.shiftindex = st.shiftindex AND tp.EQMT = e.eqmt



