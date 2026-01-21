CREATE VIEW [MOR].[CONOPS_MOR_SP_EQMT_STATUS_GANTTCHART_V] AS




--select * from [mor].[CONOPS_MOR_SP_EQMT_STATUS_GANTTCHART_V] where shiftflag = 'curr'order by eqmt

CREATE VIEW [mor].[CONOPS_MOR_SP_EQMT_STATUS_GANTTCHART_V]
AS


WITH SHIFTINFO AS(
SELECT 
a.siteflag,
a.shiftflag,
a.shiftid,
a.shiftindex,
b.ShiftStartDateTime,
b.ShiftEndDateTime
FROM [mor].[CONOPS_MOR_EQMT_SHIFT_INFO_V] a
LEFT JOIN (
SELECT 
siteflag,
shiftflag,
min(ShiftStartDateTime) AS ShiftStartDateTime,
max(ShiftEndDateTime) As ShiftEndDateTime
FROM [mor].[CONOPS_MOR_EQMT_SHIFT_INFO_V]
GROUP BY siteflag,shiftflag) b
ON a.shiftflag = b.shiftflag),

EVNTS AS (
select shiftid,eqmt,startdatetime,enddatetime,duration,reasonidx,reasons,[status]
from [mor].[asset_efficiency] WITH (NOLOCK)
where unittype = 'shovel'),

ET AS (
SELECT
shiftindex,
eqmtid,
eqmttype
FROM [dbo].[LH_EQUIP_LIST] WITH (NOLOCK)
WHERE SITE_CODE = 'MOR'
AND unit = 'Shovel'),

STAT AS (
SELECT
si.shiftid,
si.shiftflag,
si.shiftindex,
x.eqmt,
x.eqmtcurrstatus
FROM mor.CONOPS_MOR_SHIFT_INFO_V si
LEFT JOIN (
select shiftid,eqmt,[status] as eqmtcurrstatus,
ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num
from [mor].[asset_efficiency] WITH (NOLOCK)
where unittype = 'shovel') x
ON si.shiftid = x.shiftid 
WHERE x.num = 1 ),

EFH AS (
select
site_code,
shiftindex,
excav,
avg(distloaded + (fliftup * 27.1428) + (fliftdown * 16)) as EFH
FROM dbo.delta_c WITH (NOLOCK)
WHERE site_code = 'MOR'
group by shiftindex,site_code,excav),

TPRH AS (
SELECT
shiftindex,
site_code,
eqmt,
tprh 
FROM [mor].[CONOPS_MOR_SHOVEL_TPRH_V] WITH (NOLOCK)
WHERE site_code = 'MOR')


SELECT
s.shiftflag,
s.siteflag,
s.shiftid,
s.ShiftStartDateTime,
s.ShiftEndDateTime,
e.eqmt,
et.EQMTTYPE,
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
LEFT JOIn EFH efh ON efh.shiftindex = st.shiftindex AND efh.EXCAV = e.eqmt
LEFT JOIN TPRH tp ON tp.shiftindex = st.shiftindex AND tp.EQMT = e.eqmt
LEFT JOIN ET et ON s.ShiftIndex = et.SHIFTINDEX AND e.eqmt = et.EQMTID
--WHERE s.shiftflag = 'CURR'



