CREATE VIEW [sie].[CONOPS_SIE_DAILY_EOS_DRILL_NON_UTILIZED_REASON_V] AS
  
  
--SELECT * FROM [sie].[CONOPS_SIE_DAILY_EOS_DRILL_NON_UTILIZED_REASON_V] WHERE SHIFTFLAG = 'CURR'    
CREATE VIEW [sie].[CONOPS_SIE_DAILY_EOS_DRILL_NON_UTILIZED_REASON_V]    
AS    
    
 SELECT a.SHIFTFLAG  
    ,a.SiteFlag  
    ,'Drill' UnitType  
    ,[stats].Reason  
    ,SUM([stats].duration / 3600.00) AS DurationHours  
 FROM [sie].[CONOPS_SIE_EOS_SHIFT_INFO_V] A (NOLOCK)   
 LEFT JOIN [sie].[CONOPS_SIE_DAILY_DB_EQMT_STATUS_V] [stats] (NOLOCK)  
 ON a.shiftid = [stats].shiftid  
 WHERE [stats].status IN ('Delay', 'Spare')  
 GROUP BY a.SHIFTFLAG, a.SiteFlag, [stats].Reason  
  
  
