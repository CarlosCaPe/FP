CREATE VIEW [dbo].[CONOPS_LH_TP_EQMT_STATUS_V] AS


CREATE VIEW [dbo].[CONOPS_LH_TP_EQMT_STATUS_V]
AS

SELECT
shiftflag,
siteflag,
shiftid,
ShiftStartDateTime,
eqmt,
startdatetime as eventstart,
enddatetime as eventend,
duration,
reasonidx,
reasons,
[status],
eqmtcurrstatus,
avg_deltac,
avg_payload
FROM [mor].[CONOPS_MOR_TP_EQMT_STATUS_GANTTCHART_V]
WHERE siteflag = 'MOR'
AND eqmt IS NOT NULL

GROUP BY
shiftflag,siteflag,shiftid,ShiftStartDateTime,eqmt,startdatetime,enddatetime,duration,reasonidx,
reasons,[status],eqmtcurrstatus,avg_deltac,avg_payload


UNION ALL


SELECT
shiftflag,
siteflag,
shiftid,
ShiftStartDateTime,
eqmt,
startdatetime as eventstart,
enddatetime as eventend,
duration,
reasonidx,
reasons,
[status],
eqmtcurrstatus,
avg_deltac,
avg_payload
FROM [bag].[CONOPS_BAG_TP_EQMT_STATUS_GANTTCHART_V]
WHERE siteflag = 'BAG'
AND eqmt IS NOT NULL

GROUP BY
shiftflag,siteflag,shiftid,ShiftStartDateTime,eqmt,startdatetime,enddatetime,duration,reasonidx,
reasons,[status],eqmtcurrstatus,avg_deltac,avg_payload




