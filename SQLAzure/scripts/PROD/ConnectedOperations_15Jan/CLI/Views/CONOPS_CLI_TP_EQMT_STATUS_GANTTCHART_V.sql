CREATE VIEW [CLI].[CONOPS_CLI_TP_EQMT_STATUS_GANTTCHART_V] AS

--select * from [cli].[CONOPS_CLI_TP_EQMT_STATUS_GANTTCHART_V] where shiftflag = 'prev'
CREATE VIEW [cli].[CONOPS_CLI_TP_EQMT_STATUS_GANTTCHART_V] 
AS

WITH SHIFTINFO AS(
SELECT
	siteflag,
	shiftflag,
	shiftid,
	shiftindex,
	MIN(ShiftStartDateTime) OVER (PARTITION BY siteflag, shiftflag) AS ShiftStartDateTime,
	MAX(ShiftEndDateTime) OVER (PARTITION BY siteflag, shiftflag) AS ShiftEndDateTime
FROM [CLI].[CONOPS_CLI_EQMT_SHIFT_INFO_V]
),

EVNTS AS (
SELECT
	shiftid,
	eqmt,
	eqmttype,
	startdatetime,
	enddatetime,
	duration,
	reasonidx,
	reasons,
	[status]
FROM [CLI].[asset_efficiency] WITH (NOLOCK)
WHERE unittype = 'truck'
),

STAT AS (
SELECT
	si.shiftid,
	si.shiftflag,
	x.eqmt,
	x.eqmtcurrstatus
FROM CLI.CONOPS_CLI_SHIFT_INFO_V AS si
LEFT JOIN (
	SELECT
		shiftid,
		eqmt,
		[status] AS eqmtcurrstatus,
		ROW_NUMBER() OVER (
			PARTITION BY shiftid, eqmt
			ORDER BY startdatetime DESC
		) AS num
	FROM CLI.asset_efficiency WITH (NOLOCK)
	WHERE unittype = 'truck'
			AND startdatetime IS NOT NULL
) AS x
ON si.shiftid = x.shiftid
	AND x.num = 1
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
	tp.deltac AS avg_deltac,
	tp.Payload AS avg_payload
FROM SHIFTINFO s 
LEFT JOIN EVNTS e
	ON s.shiftid = e.shiftid
LEFT JOIN STAT st
	ON s.shiftflag = st.shiftflag
	AND e.eqmt = st.eqmt
LEFT JOIN CLI.CONOPS_CLI_TRUCK_POPUP tp WITH(NOLOCK)
	ON s.shiftflag = tp.shiftflag
	AND e.eqmt = tp.TruckId

