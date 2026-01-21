CREATE VIEW [bag].[CONOPS_BAG_SP_EQMT_STATUS_GANTTCHART_V] AS



--select * from [bag].[CONOPS_BAG_SP_EQMT_STATUS_GANTTCHART_V] where shiftflag = 'curr' order by eqmt

CREATE VIEW [BAG].[CONOPS_BAG_SP_EQMT_STATUS_GANTTCHART_V]
AS


WITH SHIFTINFO AS(
SELECT 
a.siteflag,
a.shiftflag,
a.shiftid,
a.shiftindex,
b.ShiftStartDateTime,
b.ShiftEndDateTime
FROM [bag].[CONOPS_BAG_EQMT_SHIFT_INFO_V] a
LEFT JOIN (
SELECT 
siteflag,
shiftflag,
min(ShiftStartDateTime) AS ShiftStartDateTime,
max(ShiftEndDateTime) As ShiftEndDateTime
FROM [bag].[CONOPS_BAG_EQMT_SHIFT_INFO_V]
GROUP BY siteflag,shiftflag) b
ON a.shiftflag = b.shiftflag),

EVNTS AS (
select shiftid,
eqmt,
eqmttype,
startdatetime,
enddatetime,
duration,
reasonidx,
reasons,
[status]
from [bag].[asset_efficiency] WITH (NOLOCK)
where unittype IN ('Shovel','Loader')),

STAT AS (
SELECT
si.shiftid,
si.shiftflag,
si.shiftindex,
x.eqmt,
x.eqmtcurrstatus
FROM bag.CONOPS_BAG_SHIFT_INFO_V si
LEFT JOIN (
select shiftid,eqmt,[status] as eqmtcurrstatus,
ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num
from [bag].[asset_efficiency] WITH (NOLOCK)
where unittype IN ('Shovel','Loader')) x
ON si.shiftid = x.shiftid 
WHERE x.num = 1 ),

EFH AS (
SELeCT
shiftindex,
excav,
avg(distloaded + (fliftup * 27.1428) + (fliftdown * 16)) as EFH
FROM dbo.delta_c WITH (NOLOCK)
WHERE site_code = 'BAG'
group by shiftdate,shiftindex,excav),

TPRH AS (
SELECT
shiftindex,
site_code,
eqmt,
tprh 
FROM [bag].[CONOPS_BAG_SHOVEL_TPRH_V] WITH (NOLOCK)
)


SELECT
s.shiftflag,
s.siteflag,
s.shiftid,
s.ShiftStartDateTime,
s.ShiftEndDateTime,
e.eqmt,
e.EQMTTYPE,
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







