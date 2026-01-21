CREATE VIEW [CLI].[CONOPS_CLI_SP_EQMT_STATUS_GANTTCHART_V] AS




--select * from [cli].[CONOPS_CLI_SP_EQMT_STATUS_GANTTCHART_V] where shiftflag = 'prev'

CREATE VIEW [cli].[CONOPS_CLI_SP_EQMT_STATUS_GANTTCHART_V]
AS


WITH SHIFTINFO AS(
SELECT 
a.siteflag,
a.shiftflag,
a.shiftid,
a.shiftindex,
b.ShiftStartDateTime,
b.ShiftEndDateTime
FROM [cli].[CONOPS_CLI_EQMT_SHIFT_INFO_V] a
LEFT JOIN (
SELECT 
siteflag,
shiftflag,
min(ShiftStartDateTime) AS ShiftStartDateTime,
max(ShiftEndDateTime) As ShiftEndDateTime
FROM [cli].[CONOPS_CLI_EQMT_SHIFT_INFO_V]
GROUP BY siteflag,shiftflag) b
ON a.shiftflag = b.shiftflag),

EVNTS AS (
select shiftid,eqmt,startdatetime,enddatetime,duration,reasonidx,reasons,[status]
from [cli].[asset_efficiency] WITH (NOLOCK)
where unittype = 'shovel'),

ET AS (
SELECT
shiftindex,
eqmtid,
eqmttype
FROM [dbo].[LH_EQUIP_LIST] WITH (NOLOCK)
WHERE SITE_CODE = 'CLI'
AND unit = 'Shovel'),

STAT AS (
SELECT
si.shiftid,
si.shiftflag,
si.shiftindex,
x.eqmt,
x.eqmtcurrstatus
FROM cli.CONOPS_CLI_SHIFT_INFO_V si
LEFT JOIN (
select shiftid,eqmt,[status] as eqmtcurrstatus,
ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num
from [cli].[asset_efficiency] WITH (NOLOCK)
where unittype = 'shovel') x
ON si.shiftid = x.shiftid 
WHERE x.num = 1 ),

EFH AS (
SELECT
shiftindex,
excav,
avg(distloaded + (fliftup * 27.1428) + (fliftdown * 16)) as EFH
FROM dbo.delta_c WITH (NOLOCK)
WHERE site_code = 'CLI'
group by shiftindex,site_code,excav),

TPRH AS (
SELECT
shiftindex,
site_code,
eqmt,
tprh 
FROM [cli].[CONOPS_CLI_SHOVEL_TPRH_V] WITH (NOLOCK)
WHERE site_code = 'CMX')


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





