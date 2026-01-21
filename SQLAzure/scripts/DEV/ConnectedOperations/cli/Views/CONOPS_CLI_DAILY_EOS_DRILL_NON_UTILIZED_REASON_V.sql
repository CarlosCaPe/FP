CREATE VIEW [cli].[CONOPS_CLI_DAILY_EOS_DRILL_NON_UTILIZED_REASON_V] AS
  
  
  
--SELECT * FROM [cli].[CONOPS_CLI_DAILY_EOS_DRILL_NON_UTILIZED_REASON_V] WHERE SHIFTFLAG = 'CURR'    
CREATE VIEW [cli].[CONOPS_CLI_DAILY_EOS_DRILL_NON_UTILIZED_REASON_V]    
AS    
    
 SELECT a.SHIFTFLAG  
    ,a.SiteFlag  
    ,'Drill' UnitType  
    ,[stats].Reason  
    ,SUM([stats].duration / 3600.00) AS DurationHours  
 FROM [cli].[CONOPS_CLI_EOS_SHIFT_INFO_V] A (NOLOCK)   
 LEFT JOIN [cli].[CONOPS_CLI_DAILY_DB_EQMT_STATUS_V] [stats] (NOLOCK)  
 ON a.SHIFTFLAG = [stats].SHIFTFLAG  
 WHERE [stats].status IN ('Delay', 'Spare')  
 GROUP BY a.SHIFTFLAG, a.SiteFlag, [stats].Reason  
  
  
