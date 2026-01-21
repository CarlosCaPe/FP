CREATE VIEW [CER].[CONOPS_CER_DB_EQMT_STATUS_GANTTCHART_V] AS
  
  
  
  
--select * from [cer].[CONOPS_CER_DB_EQMT_STATUS_GANTTCHART_V] where shiftflag = 'prev'  
CREATE VIEW [cer].[CONOPS_CER_DB_EQMT_STATUS_GANTTCHART_V]  
AS  
  
WITH SHIFTINFO AS (  
   SELECT a.siteflag,  
             a.shiftflag,  
             a.shiftid,  
             a.shiftindex * 10 AS shiftindex,  
             b.ShiftStartDateTime,  
             b.ShiftEndDateTime  
      FROM [cer].[CONOPS_CER_EQMT_SHIFT_INFO_V] a  
      LEFT JOIN (  
      SELECT siteflag,  
                   shiftflag,  
                   min(ShiftStartDateTime) AS ShiftStartDateTime,  
                   max(ShiftEndDateTime) AS ShiftEndDateTime  
            FROM [cer].[CONOPS_CER_EQMT_SHIFT_INFO_V] WITH (NOLOCK)  
            GROUP BY siteflag,  
                     shiftflag  
  ) b ON a.shiftflag = b.shiftflag  
),  
EVNTS AS (  
   SELECT ShiftId,  
    eqmt,  
             startdatetime,  
             enddatetime,  
             duration,  
             reasonidx,  
             reasons,  
             [status]  
      FROM [cer].[asset_efficiency_v] (NOLOCK)  
   WHERE UnitType = 'Drill'  
),  
  
ET AS (  
SELECT  
shiftindex,  
eqmtid,  
eqmttype  
FROM [dbo].[LH_EQUIP_LIST]  
WHERE SITE_CODE = 'CER'  
AND unit = 'Perf. Prim.'),  
  
STAT AS (  
   SELECT  
   si.shiftid,  
   si.shiftflag,  
   si.shiftindex,  
   x.eqmt,  
   x.eqmtcurrstatus  
   FROM cer.CONOPS_CER_SHIFT_INFO_V si  
   LEFT JOIN (  
     
      SELECT ShiftId,  
                   eqmt,  
                   [status] AS eqmtcurrstatus,  
                   ROW_NUMBER() OVER (PARTITION BY ShiftId,  
                                                   eqmt  
                                      ORDER BY startdatetime DESC) num  
            FROM [cer].[asset_efficiency_v] (NOLOCK)  
   WHERE UnitType = 'Drill'  
   ) x ON si.SHIFTID = x.ShiftId  
      WHERE x.num = 1  
),  
  
NrOfHoles AS (  
   SELECT h.shiftindex,  
             h.DRILL_ID AS eqmt,  
             h.holes,  
    h.score,
	h.Elevation
      FROM (  
  SELECT SHIFTINDEX,  
      SITE_CODE,  
      REPLACE(DRILL_ID, ' ','') AS DRILL_ID,  
      COUNT(DRILL_HOLE) AS holes,  
      AVG(OVERALLSCORE) AS score,
	  ROUND(AVG(START_POINT_Z),0) Elevation
  FROM [dbo].[FR_DRILLING_SCORES] [ds] WITH (NOLOCK)  
  WHERE SITE_CODE = 'CER'  
  GROUP BY SHIFTINDEX, SITE_CODE, DRILL_ID  
   ) h  
)  
  
SELECT s.shiftflag,  
       s.siteflag,  
       s.shiftid,  
       s.ShiftStartDateTime,  
       s.ShiftEndDateTime,  
       e.eqmt,  
    st.eqmtcurrstatus,  
    et.eqmttype,  
       e.startdatetime,  
       e.enddatetime,  
       e.duration,  
       e.reasonidx,  
       e.reasons,  
       e.[status],  
       nh.holes,  
    nh.score,
	nh.Elevation
FROM SHIFTINFO s  
LEFT JOIN EVNTS e ON s.shiftid = e.ShiftId  
LEFT JOIN STAT st ON s.shiftflag = st.shiftflag AND e.eqmt = st.eqmt  
LEFT JOIN NrOfHoles nh ON st.ShiftIndex = nh.ShiftIndex AND e.eqmt = nh.eqmt  
LEFT JOIN ET et ON s.shiftindex = et.shiftindex AND et.EQMTID = e.EQMT  
WHERE e.eqmt IS NOT NULL  
  
  
  
  
