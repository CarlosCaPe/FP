CREATE VIEW [CHI].[CONOPS_CHI_DAILY_EOS_IOS_STOCKPILE_V] AS
  
    
  
--SELECT * FROM [chi].[CONOPS_CHI_DAILY_EOS_IOS_STOCKPILE_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'CURR'      
CREATE VIEW [chi].[CONOPS_CHI_DAILY_EOS_IOS_STOCKPILE_V]      
AS      
    
 --WITH stockpile AS (    
 -- SELECT [SITEFLAG],    
 --     [SHIFTINDEX],    
 --     [CRUSHERLOC],    
 --     CrusherStockpile,    
 --     CrusherStockpileTons    
 -- FROM (    
 --  SELECT [SITEFLAG]    
 --     ,[SHIFTINDEX]    
 --     ,[CRUSHERLOC]    
 --     ,[COMPONENT]    
 --     ,[SENSORVALUE]    
 --  FROM [chi].[IOS_STOCKPILE_LEVELS]    
 -- ) src    
 -- PIVOT    
 -- (AVG([SENSORVALUE]) FOR [COMPONENT]  IN (CrusherStockpile, CrusherStockpileTons)) AS PivotTable    
 --)    
    
 SELECT a.[SITEFLAG]    
    ,a.[SHIFTFLAG]    
    ,'CRUSHER' AS [CRUSHERLOC]    
    ,0 AS CrusherStockpile    
    ,0 AS CrusherStockpileTons    
 FROM [chi].[CONOPS_CHI_EOS_SHIFT_INFO_V] a WITH (NOLOCK)    
 --LEFT JOIN stockpile [is] WITH (NOLOCK)    
 --ON a.SHIFTINDEX = [is].SHIFTINDEX    
    
    
    
  
