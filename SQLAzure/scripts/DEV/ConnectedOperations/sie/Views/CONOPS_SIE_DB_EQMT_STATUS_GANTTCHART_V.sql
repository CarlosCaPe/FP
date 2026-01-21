CREATE VIEW [sie].[CONOPS_SIE_DB_EQMT_STATUS_GANTTCHART_V] AS
  
  
  
  
--select * from [sie].[CONOPS_SIE_DB_EQMT_STATUS_GANTTCHART_V] where shiftflag = 'prev'  
CREATE VIEW [sie].[CONOPS_SIE_DB_EQMT_STATUS_GANTTCHART_V]  
AS  
  
WITH SHIFTINFO AS (  
   SELECT a.siteflag,  
             a.shiftflag,  
             a.shiftid,  
             a.shiftindex,  
             b.ShiftStartDateTime,  
             b.ShiftEndDateTime  
      FROM [sie].[CONOPS_SIE_EQMT_SHIFT_INFO_V] a  
      LEFT JOIN (  
      SELECT siteflag,  
                   shiftflag,  
                   min(ShiftStartDateTime) AS ShiftStartDateTime,  
                   max(ShiftEndDateTime) AS ShiftEndDateTime  
            FROM [sie].[CONOPS_SIE_EQMT_SHIFT_INFO_V]  
            GROUP BY siteflag,  
                     shiftflag  
  ) b ON a.shiftflag = b.shiftflag  
),  
  
EVNTS AS (  
   SELECT SHIFTINDEX,  
             SITE_CODE AS siteflag,  
    DRILL_ID AS eqmt,  
             startdatetime,  
             enddatetime,  
             duration,  
             reasonidx,  
             reason AS reasons,  
             [status]  
      FROM [sie].[drill_asset_efficiency_v] (NOLOCK)  
),  
  
STAT AS (  
   SELECT  
   si.shiftid,  
   si.shiftflag,  
   si.shiftindex,  
   x.eqmt,  
   x.eqmtcurrstatus,  
   x.eqmttype  
   FROM sie.CONOPS_SIE_SHIFT_INFO_V si  
   LEFT JOIN (  
     
      SELECT SHIFTINDEX,  
                   DRILL_ID AS eqmt,  
                   [status] AS eqmtcurrstatus,  
       [MODEL] AS eqmttype,  
                   ROW_NUMBER() OVER (PARTITION BY SHIFTINDEX,  
                                                   DRILL_ID  
                                      ORDER BY startdatetime DESC) num  
            FROM [sie].[drill_asset_efficiency_v] (NOLOCK)  
   ) x ON si.shiftindex = x.SHIFTINDEX  
      WHERE x.num = 1  
),  
  
NrOfHoles AS (  
   SELECT h.shiftindex,  
             h.DRILL_ID AS eqmt,  
             h.holes,  
    h.score ,
	h.Elevation
      FROM (  
  SELECT SHIFTINDEX,  
      SITE_CODE,  
      'DR' + RIGHT(DRILL_ID, 2) AS DRILL_ID,  
      COUNT(DRILL_HOLE) AS holes,  
      AVG(OVERALLSCORE) AS score,
	  ROUND(AVG(START_POINT_Z),0) Elevation
  FROM [dbo].[FR_DRILLING_SCORES] [ds] WITH (NOLOCK)  
  WHERE SITE_CODE = 'SIE'  
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
    st.eqmttype,  
       e.startdatetime,  
       e.enddatetime,  
       e.duration,  
       e.reasonidx,  
       e.reasons,  
       e.[status],  
       nh.holes,  
    nh.score  ,
	nh.Elevation
FROM SHIFTINFO s  
LEFT JOIN EVNTS e ON s.ShiftIndex = e.SHIFTINDEX  
LEFT JOIN STAT st ON s.shiftflag = st.shiftflag AND e.eqmt = st.eqmt  
LEFT JOIN NrOfHoles nh ON st.shiftindex = nh.shiftindex AND e.eqmt = nh.eqmt  
WHERE e.eqmt IS NOT NULL AND e.eqmt <> 'DR81'  
  
  
  
  
  
