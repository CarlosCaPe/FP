CREATE VIEW [chi].[CONOPS_CHI_DAILY_EOS_SHOVEL_NON_UTILIZED_REASON_V] AS
  
  
  
  
--SELECT * FROM [CHI].[CONOPS_CHI_DAILY_EOS_SHOVEL_NON_UTILIZED_REASON_V] WHERE SHIFTFLAG = 'CURR'    
CREATE VIEW [CHI].[CONOPS_CHI_DAILY_EOS_SHOVEL_NON_UTILIZED_REASON_V]    
AS    
    
 SELECT a.SHIFTFLAG  
    ,a.SiteFlag  
    ,'Shovel' UnitType  
    --,se.status AS Status  
    --,se.reason AS DelayReasonCode  
    ,rt.name AS Reason  
    ,SUM(se.duration / 3600) AS DurationHours  
 FROM [CHI].[CONOPS_CHI_EOS_SHIFT_INFO_V] A (NOLOCK)   
 LEFT JOIN [dbo].[status_event] se WITH (NOLOCK)  
 ON a.SHIFTINDEX = se.shiftindex AND a.SITEFLAG = se.site_code  
 LEFT JOIN [dbo].[lh_reason] rt WITH (NOLOCK)  
 ON se.shiftindex = rt.shiftindex AND se.site_code = rt.SITE_CODE  
    AND se.status = rt.status AND se.reason = rt.reason  
 WHERE se.site_code = 'CHI'  
 AND se.unit = 2   
 AND (se.category = 3 OR se.status IN (3, 4))  
 AND rt.name IS NOT NULL  
 GROUP BY a.SHIFTFLAG, a.SiteFlag, rt.name  
  
  
