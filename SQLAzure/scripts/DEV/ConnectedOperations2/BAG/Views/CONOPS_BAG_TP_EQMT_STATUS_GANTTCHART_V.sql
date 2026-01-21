CREATE VIEW [BAG].[CONOPS_BAG_TP_EQMT_STATUS_GANTTCHART_V] AS






--select * from [bag].[CONOPS_BAG_TP_EQMT_STATUS_GANTTCHART_V] where shiftflag = 'curr'

CREATE VIEW [bag].[CONOPS_BAG_TP_EQMT_STATUS_GANTTCHART_V]
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
select shiftid,eqmt,eqmttype,startdatetime,enddatetime,duration,reasonidx,reasons,[status]
from [bag].[asset_efficiency] WITH (NOLOCK)
where unittype = 'Truck'),

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
where unittype = 'Truck') x
ON si.shiftid = x.shiftid 
WHERE x.num = 1 ),

DC AS (
select 
shiftindex,
truck, avg(delta_c) as avg_deltac
from [dbo].[delta_c] WITH (NOLOCK)
where site_code = 'BAG'
group by shiftindex,truck),

PL AS (
SELECT shiftflag,truck, avg_payload
FROM [bag].[CONOPS_BAG_TP_AVG_PAYLOAD_V] WITH (NOLOCK)
WHERE siteflag = 'BAG')


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
dc.avg_deltac,
pl.avg_payload
FROM SHIFTINFO s 
LEFT JOIN EVNTS e ON s.shiftid = e.shiftid 
LEFT JOIN STAT st ON s.shiftflag = st.shiftflag AND e.eqmt = st.eqmt
LEFT JOIn DC dc ON dc.shiftindex = st.shiftindex AND dc.truck = e.eqmt
LEFT JOIN PL pl ON pl.shiftflag = st.shiftflag AND pl.truck = e.eqmt






