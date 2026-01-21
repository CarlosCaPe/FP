CREATE VIEW [bag].[CONOPS_BAG_DAILY_EOS_IOS_STOCKPILE_V] AS
  
    
   
--SELECT * FROM [bag].[CONOPS_BAG_DAILY_EOS_IOS_STOCKPILE_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'CURR'      
CREATE VIEW [bag].[CONOPS_BAG_DAILY_EOS_IOS_STOCKPILE_V]      
AS      
  
  
WITH CTE AS (  
SELECT   
[SITEFLAG]    
,[SHIFTINDEX]    
,[CRUSHERLOC]    
,[COMPONENT]    
,[SENSORVALUE],  
ROW_NUMBER() OVER (PARTITION BY SHIFTINDEX,CRUSHERLOC,COMPONENT ORDER BY VALUE_TS DESC) NUM    
FROM [dbo].[IOS_STOCKPILE_LEVELS] WITH (NOLOCK)    
WHERE [SITEFLAG] = 'BAG'),  
  
CrLocShift AS (    
SELECT   
a.SHIFTINDEX,    
a.SHIFTFLAG,    
a.SITEFLAG,    
'CRUSHER 2' AS CrusherLoc    
FROM [bag].[CONOPS_BAG_EOS_SHIFT_INFO_V] a WITH (NOLOCK)    
 ),    
     
stockpile AS (    
SELECT   
[SITEFLAG],    
[SHIFTINDEX],    
[CRUSHERLOC],    
CrusherStockpile,    
CrusherStockpileTons    
FROM (    
SELECT   
[SITEFLAG]    
,[SHIFTINDEX]    
,[CRUSHERLOC]    
,[COMPONENT]    
,[SENSORVALUE]  
FROM CTE  
WHERE NUM = 1) src    
  
PIVOT    
(AVG([SENSORVALUE]) FOR [COMPONENT]  IN (CrusherStockpile, CrusherStockpileTons)) AS PivotTable)    
    
SELECT   
cl.[SITEFLAG]    
,cl.[SHIFTFLAG]    
,cl.[CRUSHERLOC]    
,CrusherStockpile    
,CrusherStockpileTons    
FROM CrLocShift cl WITH (NOLOCK)    
LEFT JOIN stockpile [is] WITH (NOLOCK)    
ON cl.SHIFTINDEX = [is].SHIFTINDEX AND cl.CrusherLoc = [is].CRUSHERLOC    
    
    
    
  
