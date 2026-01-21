CREATE VIEW [saf].[CONOPS_SAF_DAILY_EOS_IOS_STOCKPILE_V] AS
  
    
    
    
    
--SELECT * FROM [saf].[CONOPS_SAF_DAILY_EOS_IOS_STOCKPILE_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'CURR'      
CREATE VIEW [saf].[CONOPS_SAF_DAILY_EOS_IOS_STOCKPILE_V]      
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
WHERE [SITEFLAG] = 'SAF'),  
  
  
CrLocShift AS (    
SELECT   
a.SHIFTINDEX,    
a.SHIFTFLAG,    
a.SITEFLAG,    
'CRUSHER' AS CrusherLoc    
FROM [saf].[CONOPS_SAF_EOS_SHIFT_INFO_V] a WITH (NOLOCK)    
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
FROM CTE WITH (NOLOCK)    
WHERE NUM = 1  
) src    
PIVOT    
(AVG([SENSORVALUE]) FOR [COMPONENT]  IN (CrusherStockpile, CrusherStockpileTons)) AS PivotTable )    
    
SELECT   
a.[SITEFLAG]    
,a.[SHIFTFLAG]    
,a.[CRUSHERLOC]    
,CrusherStockpile    
,CrusherStockpileTons    
FROM CrLocShift a WITH (NOLOCK)    
LEFT JOIN stockpile [is] WITH (NOLOCK)    
ON a.SHIFTINDEX = [is].SHIFTINDEX AND a.CrusherLoc = [is].CRUSHERLOC    
    
    
    
  
