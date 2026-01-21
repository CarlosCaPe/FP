CREATE VIEW [Arch].[CONOPS_ARCH_TP_EQMT_STATUS_GANTTCHART_V] AS


CREATE VIEW [Arch].[CONOPS_ARCH_TP_EQMT_STATUS_GANTTCHART_V]
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
where unittype = 'truck'),

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
where unittype = 'truck') x
ON si.shiftid = x.shiftid 
WHERE x.num = 1 
AND si.siteflag = '<SITECODE>'),

DC AS (
select 
concat(concat(right(replace(cast(shiftdate as varchar(10)),'-',''),6),'00'),shift_code) as shiftid,
truck, avg(delta_c) as avg_deltac
from [dbo].[delta_c] (NOLOCK)
--WHERE site_code = '<SITECODE>'
group by shiftdate,shift_code,truck),

PL AS (
SELECT shiftflag,truck, avg_payload
FROM [Arch].[CONOPS_ARCH_TP_AVG_PAYLOAD_V] (NOLOCK)
WHERE siteflag = '<SITECODE>'
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
dc.avg_deltac,
pl.avg_payload
FROM SHIFTINFO s 
LEFT JOIN EVNTS e ON s.shiftid = e.shiftid 
LEFT JOIN STAT st ON s.shiftflag = st.shiftflag AND e.eqmt = st.eqmt
LEFT JOIn DC dc ON dc.shiftid = st.shiftid AND dc.truck = e.eqmt
LEFT JOIN PL pl ON pl.shiftflag = st.shiftflag AND pl.truck = e.eqmt



