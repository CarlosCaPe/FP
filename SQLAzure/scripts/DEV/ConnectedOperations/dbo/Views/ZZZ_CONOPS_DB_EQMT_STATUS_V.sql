CREATE VIEW [dbo].[ZZZ_CONOPS_DB_EQMT_STATUS_V] AS


--select * from [dbo].[CONOPS_DB_EQMT_STATUS_V] where shiftflag = 'curr'
CREATE VIEW [dbo].[CONOPS_DB_EQMT_STATUS_V]
AS

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
       holes,
	   score
FROM [mor].[CONOPS_MOR_DB_EQMT_STATUS_GANTTCHART_V] (NOLOCK)
WHERE siteflag = 'MOR'
     AND eqmt IS NOT NULL

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
       holes,
	   score
FROM [bag].[CONOPS_BAG_DB_EQMT_STATUS_GANTTCHART_V] (NOLOCK)
WHERE siteflag = 'BAG'
     AND eqmt IS NOT NULL

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
       holes,
	   score
FROM [saf].[CONOPS_SAF_DB_EQMT_STATUS_GANTTCHART_V] (NOLOCK)
WHERE siteflag = 'SAF'
     AND eqmt IS NOT NULL

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
       holes,
	   score
FROM [sie].[CONOPS_SIE_DB_EQMT_STATUS_GANTTCHART_V] (NOLOCK)
WHERE siteflag = 'SIE'
     AND eqmt IS NOT NULL


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
       holes,
	   score
FROM [cli].[CONOPS_CLI_DB_EQMT_STATUS_GANTTCHART_V] (NOLOCK)
WHERE siteflag = 'CMX'
     AND eqmt IS NOT NULL

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
       holes,
	   score
FROM [chi].[CONOPS_CHI_DB_EQMT_STATUS_GANTTCHART_V] (NOLOCK)
WHERE siteflag = 'CHI'
     AND eqmt IS NOT NULL

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
       holes,
	   score
FROM [cer].[CONOPS_CER_DB_EQMT_STATUS_GANTTCHART_V] (NOLOCK)
WHERE siteflag = 'CER'
     AND eqmt IS NOT NULL
