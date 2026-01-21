CREATE VIEW [ABR].[CONOPS_ABR_DAILY_EOS_KPI_SUMMARY_HOURLY_AVG_DURATION_V] AS



  
-- SELECT * FROM [abr].[CONOPS_ABR_DAILY_EOS_KPI_SUMMARY_HOURLY_AVG_DURATION_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'CURR'    
CREATE VIEW [ABR].[CONOPS_ABR_DAILY_EOS_KPI_SUMMARY_HOURLY_AVG_DURATION_V]    
AS    
    
WITH CteStatusEvent AS (  
 SELECT ShiftIndex  
  ,Site_Code AS SiteFlag  
  ,dw_load_ts  
  ,Duration  
 FROM [dbo].[status_event] WITH (NOLOCK)  
 WHERE Site_Code = 'ELA'  
 AND Status = 4  
 AND Reason = 401  
 AND Unit = 1  
),  
  
  
StatusEvent AS (  
 SELECT [se].ShiftIndex  
  ,[se].ShiftFlag  
  ,[se].SiteFlag  
  ,[se].shiftid
  ,[se].Duration  
  ,[se].ShiftStartDateTime  
  ,DATEADD(hh, IIF(HOS = 0, 0, HOS - 1), ShiftStartDateTime) AS Hr  
  ,IIF(HOS = 0, 1, HOS) AS HOS   
 FROM (  
  SELECT [si].ShiftIndex  
   ,[si].ShiftFlag  
   ,[si].SiteFlag  
   ,[si].shiftid
   ,[cse].Duration  
   ,[si].ShiftStartDateTime  
   ,CEILING(DATEDIFF(MINUTE, [si].ShiftStartDateTime, [cse].dw_load_ts) / 60.00) as HOS  
  FROM [abr].[CONOPS_ABR_EOS_SHIFT_INFO_V] [si] WITH (NOLOCK)  
  LEFT JOIN CteStatusEvent [cse]  
   ON [si].ShiftIndex = [cse].ShiftIndex  
   --AND [si].SiteFlag = [cse].SiteFlag  
 ) AS [se]  
)  
  
SELECT ShiftIndex  
 ,ShiftFlag  
 ,shiftid
 ,SiteFlag  
 ,CAST( COALESCE( AVG( Duration)/ 60, 0) AS DECIMAL(7,2)) AS [AvgDuration]  
 ,Hr  
 ,Hos  
FROM StatusEvent   
GROUP BY ShiftIndex, SiteFlag, ShiftFlag, Hos, Hr,shiftid
  
  

