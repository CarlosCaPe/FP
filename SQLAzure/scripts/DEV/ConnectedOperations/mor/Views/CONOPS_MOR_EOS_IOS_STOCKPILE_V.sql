CREATE VIEW [mor].[CONOPS_MOR_EOS_IOS_STOCKPILE_V] AS
  

--SELECT * FROM [mor].[CONOPS_MOR_EOS_IOS_STOCKPILE_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'CURR'    
CREATE VIEW [mor].[CONOPS_MOR_EOS_IOS_STOCKPILE_V]    
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
WHERE [SITEFLAG] = 'MOR'),


CrLoc AS (  
SELECT 'Crusher 2' CrusherLoc  
UNION ALL  
SELECT 'Crusher 3' CrusherLoc  
),  
  
CrLocShift AS (  
SELECT 
a.SHIFTINDEX,  
a.SHIFTFLAG,  
a.SITEFLAG,  
CrusherLoc  
FROM CrLoc, [mor].[CONOPS_MOR_SHIFT_INFO_V] a WITH (NOLOCK)  
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
  
  
  
