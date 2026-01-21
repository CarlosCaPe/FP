CREATE VIEW [dbo].[CONOPS_LH_SP_EQMT_STATUS_V] AS


CREATE VIEW [dbo].[CONOPS_LH_SP_EQMT_STATUS_V]
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
EFH,
TPRH
FROM [mor].[CONOPS_MOR_SP_EQMT_STATUS_GANTTCHART_V] (NOLOCK)
WHERE siteflag = 'MOR'
AND eqmt IS NOT NULL

GROUP BY 
shiftflag,siteflag,shiftid,ShiftStartDateTime,eqmt,startdatetime,enddatetime,duration,reasonidx,
reasons,[status],eqmtcurrstatus,EFH,TPRH


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
EFH,
TPRH
FROM [bag].[CONOPS_BAG_SP_EQMT_STATUS_GANTTCHART_V] (NOLOCK)
WHERE siteflag = 'BAG'
AND eqmt IS NOT NULL

GROUP BY 
shiftflag,siteflag,shiftid,ShiftStartDateTime,eqmt,startdatetime,enddatetime,duration,reasonidx,
reasons,[status],eqmtcurrstatus,EFH,TPRH



