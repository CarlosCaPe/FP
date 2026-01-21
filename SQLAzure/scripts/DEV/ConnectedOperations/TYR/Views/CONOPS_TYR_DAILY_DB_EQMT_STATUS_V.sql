CREATE VIEW [TYR].[CONOPS_TYR_DAILY_DB_EQMT_STATUS_V] AS

  
  
    
    
--SELECT * FROM [tyr].[CONOPS_TYR_DAILY_DB_EQMT_STATUS_V] WHERE SHIFTFLAG = 'CURR'    
CREATE VIEW [tyr].[CONOPS_TYR_DAILY_DB_EQMT_STATUS_V]    
AS    
    
SELECT A.SHIFTFLAG,    
       A.SITEFLAG,    
       A.SHIFTID,    
       A.SHIFTSTARTDATETIME,    
       A.SHIFTENDDATETIME,    
       B.EQMT,    
       B.STARTDATETIME,    
       B.ENDDATETIME,    
       B.DURATION,    
       B.REASONIDX,    
       B.REASON,    
       B.[STATUS],    
       C.EQMTCURRSTATUS,    
    C.EQMTTYPE,  
       D.[HOLES]    
FROM [tyr].[CONOPS_TYR_EOS_SHIFT_INFO_V] A (NOLOCK)    
LEFT JOIN (    
   SELECT SHIFTINDEX,    
    DRILL_ID AS EQMT,    
             STARTDATETIME,    
             ENDDATETIME,    
             DURATION,    
             REASONIDX,    
             REASON,    
             [STATUS]    
      FROM [tyr].[DRILL_ASSET_EFFICIENCY_V] (NOLOCK)    
) B ON A.SHIFTINDEX = B.SHIFTINDEX    
LEFT JOIN (    
   SELECT SHIFTINDEX,    
             DRILL_ID,    
             STARTDATETIME,    
             ENDDATETIME,    
             [STATUS] AS EQMTCURRSTATUS,  
    [MODEL] AS EQMTTYPE,  
             ROW_NUMBER() OVER (PARTITION BY SHIFTINDEX,    
                                             DRILL_ID    
                                ORDER BY STARTDATETIME DESC) NUM    
      FROM [tyr].[DRILL_ASSET_EFFICIENCY_V] (NOLOCK)    
) C ON B.SHIFTINDEX = C.SHIFTINDEX AND B.EQMT = C.DRILL_ID    
LEFT JOIN (    
 SELECT  SHIFTINDEX,    
   SITE_CODE,    
   DRILL_ID,    
   COUNT(DRILL_HOLE) AS HOLES    
 FROM [DBO].[FR_DRILLING_SCORES] [DS] WITH (NOLOCK)    
 WHERE SITE_CODE = 'TYR'    
 GROUP BY SHIFTINDEX, SITE_CODE, DRILL_ID    
) D ON A.SHIFTINDEX = D.SHIFTINDEX AND B.EQMT = D.DRILL_ID    
WHERE C.NUM = 1    
    
  
  
