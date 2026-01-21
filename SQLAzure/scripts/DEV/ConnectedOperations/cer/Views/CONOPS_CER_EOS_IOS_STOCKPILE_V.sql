CREATE VIEW [cer].[CONOPS_CER_EOS_IOS_STOCKPILE_V] AS


  

--SELECT * FROM [cer].[CONOPS_CER_EOS_IOS_STOCKPILE_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'CURR'    
CREATE VIEW [cer].[CONOPS_CER_EOS_IOS_STOCKPILE_V]    
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
WHERE [SITEFLAG] = 'CER'
AND CRUSHERLOC <> 'HIDROCHAN'),


CrLoc AS (  
SELECT 'MILLCHAN' CrusherLoc  
UNION ALL  
SELECT 'MILLCRUSH1' CrusherLoc  
UNION ALL  
SELECT 'MILLCRUSH2' CrusherLoc  
--UNION ALL  
--SELECT 'HIDROCHAN' CrusherLoc 
),  
  
CrLocShift AS (  
SELECT 
a.SHIFTINDEX,  
a.SHIFTFLAG,  
a.SITEFLAG,  
CrusherLoc  
FROM CrLoc, [cer].[CONOPS_CER_SHIFT_INFO_V] a WITH (NOLOCK)  ),  
  
stockpile AS (  
SELECT 
[SITEFLAG],  
[SHIFTINDEX],  
CASE [CRUSHERLOC]  
WHEN 'C1 MillChan' THEN 'MILLCHAN'  
WHEN 'MillCrush 1' THEN 'MILLCRUSH1'  
WHEN 'MillCrush 2' THEN 'MILLCRUSH2'  
ELSE [CRUSHERLOC]  END AS [CRUSHERLOC],  
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
  
  
  

