CREATE VIEW [dbo].[CONOPS_LH_TP_EQMT_STATUS_V] AS





--select * from [dbo].[CONOPS_LH_TP_EQMT_STATUS_V] where shiftflag = 'curr' and siteflag = 'SAF'

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


UNION ALL

SELECT shiftflag,
       siteflag,
       shiftid,
       ShiftStartDateTime,
       eqmt,
       startdatetime AS eventstart,
       enddatetime AS eventend,
       duration,
       reasonidx,
       reasons,
       [status],
       eqmtcurrstatus,
       avg_deltac,
       avg_payload
FROM [saf].[CONOPS_SAF_TP_EQMT_STATUS_GANTTCHART_V]
WHERE siteflag = 'SAF'
      AND eqmt IS NOT NULL
GROUP BY shiftflag, siteflag, shiftid, ShiftStartDateTime, eqmt, startdatetime, enddatetime, 
		 duration, reasonidx, reasons, [status], eqmtcurrstatus, avg_deltac, avg_payload


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
FROM [sie].[CONOPS_SIE_TP_EQMT_STATUS_GANTTCHART_V]
WHERE siteflag = 'SIE'
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
FROM [cli].[CONOPS_CLI_TP_EQMT_STATUS_GANTTCHART_V]
WHERE siteflag = 'CMX'
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
FROM [chi].[CONOPS_CHI_TP_EQMT_STATUS_GANTTCHART_V]
WHERE siteflag = 'CHI'
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
FROM [cer].[CONOPS_CER_TP_EQMT_STATUS_GANTTCHART_V]
WHERE siteflag = 'CER'
AND eqmt IS NOT NULL

GROUP BY
shiftflag,siteflag,shiftid,ShiftStartDateTime,eqmt,startdatetime,enddatetime,duration,reasonidx,
reasons,[status],eqmtcurrstatus,avg_deltac,avg_payload

