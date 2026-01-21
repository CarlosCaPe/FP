CREATE VIEW [CHI].[CONOPS_CHI_TP_EQMT_STATUS_GANTTCHART_V] AS




--select * from [chi].[CONOPS_CHI_TP_EQMT_STATUS_GANTTCHART_V] where shiftflag = 'prev'

CREATE VIEW [chi].[CONOPS_CHI_TP_EQMT_STATUS_GANTTCHART_V] 
AS

WITH SHIFTINFO AS (
	 SELECT a.siteflag,
            a.shiftflag,
            a.shiftid,
            a.shiftindex,
            b.ShiftStartDateTime,
            b.ShiftEndDateTime
     FROM [chi].[CONOPS_CHI_EQMT_SHIFT_INFO_V] a
     LEFT JOIN (
		  SELECT siteflag,
                 shiftflag,
                 min(ShiftStartDateTime) AS ShiftStartDateTime,
                 max(ShiftEndDateTime) AS ShiftEndDateTime
          FROM [chi].[CONOPS_CHI_EQMT_SHIFT_INFO_V]
          GROUP BY siteflag,
                   shiftflag) b
	 ON a.shiftflag = b.shiftflag
),

EVNTS AS (
	 SELECT shiftid,
            eqmt,
            startdatetime,
            enddatetime,
            duration,
            reasonidx,
            reasons,
            [status]
     FROM [chi].[asset_efficiency] WITH (NOLOCK)
     WHERE unittype = 'truck'
	 AND eqmt NOT IN ('897','898')
),

ET AS (
SELECT
shiftindex,
eqmtid,
eqmttype
FROM [dbo].[LH_EQUIP_LIST] WITH (NOLOCK)
WHERE SITE_CODE = 'CHI'
AND unit = 'Truck'),

STAT AS (
SELECT
si.shiftid,
si.shiftflag,
si.shiftindex,
x.eqmt,
x.eqmtcurrstatus
FROM chi.CONOPS_CHI_SHIFT_INFO_V si
LEFT JOIN (
select shiftid,eqmt,[status] as eqmtcurrstatus,
ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num
from [chi].[asset_efficiency] WITH (NOLOCK)
where unittype = 'truck') x
ON si.shiftid = x.shiftid 
WHERE x.num = 1 ),

DC AS (
	 SELECT shiftindex,
            truck,
            avg(delta_c) AS avg_deltac
     FROM [dbo].[delta_c] WITH (NOLOCK)
     WHERE site_code = 'CHI'
     GROUP BY shiftindex, truck
),

PL AS (
	 SELECT shiftflag,
            truck,
            avg_payload
     FROM [chi].[CONOPS_CHI_TP_AVG_PAYLOAD_V] WITH (NOLOCK)
     WHERE siteflag = 'CHI'
)

SELECT s.shiftflag,
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
       dc.avg_deltac,
       pl.avg_payload
FROM SHIFTINFO s
LEFT JOIN EVNTS e ON s.shiftid = e.shiftid
LEFT JOIN STAT st ON s.shiftflag = st.shiftflag AND e.eqmt = st.eqmt
LEFT JOIN DC dc ON dc.shiftindex = st.shiftindex AND dc.truck = e.eqmt
LEFT JOIN PL pl ON pl.shiftflag = st.shiftflag AND pl.truck = e.eqmt
LEFT JOIN ET et ON s.ShiftIndex = et.SHIFTINDEX AND e.eqmt = et.EQMTID



