CREATE VIEW [dbo].[CONOPS_LH_SP_EQMT_STATUS_V] AS









--select * from [dbo].[CONOPS_LH_SP_EQMT_STATUS_V] where shiftflag = 'curr'

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
FROM [saf].[CONOPS_SAF_SP_EQMT_STATUS_GANTTCHART_V] (NOLOCK)
WHERE siteflag = 'SAF'
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
FROM [sie].[CONOPS_SIE_SP_EQMT_STATUS_GANTTCHART_V] (NOLOCK)
WHERE siteflag = 'SIE'
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
FROM [cli].[CONOPS_CLI_SP_EQMT_STATUS_GANTTCHART_V] (NOLOCK)
WHERE siteflag = 'CMX'
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
FROM [chi].[CONOPS_CHI_SP_EQMT_STATUS_GANTTCHART_V] (NOLOCK)
WHERE siteflag = 'CHI'
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
FROM [cer].[CONOPS_CER_SP_EQMT_STATUS_GANTTCHART_V] (NOLOCK)
WHERE siteflag = 'CER'
AND eqmt IS NOT NULL
GROUP BY 
shiftflag,siteflag,shiftid,ShiftStartDateTime,eqmt,startdatetime,enddatetime,duration,reasonidx,
reasons,[status],eqmtcurrstatus,EFH,TPRH
