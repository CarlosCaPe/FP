CREATE VIEW [SIE].[CONOPS_SIE_EOS_IOS_STOCKPILE_V] AS
  
  
  
  
  
--SELECT * FROM [sie].[CONOPS_SIE_EOS_IOS_STOCKPILE_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'CURR'    
CREATE VIEW [sie].[CONOPS_SIE_EOS_IOS_STOCKPILE_V]    
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
WHERE [SITEFLAG] = 'SIE'),


CrLoc AS (  
SELECT 'Crusher' CrusherLoc  
UNION ALL  
SELECT 'A-SIDE' CrusherLoc  
UNION ALL  
SELECT 'B-SIDE' CrusherLoc  
),  
  
CrLocShift AS (  
SELECT 
a.SHIFTINDEX,  
a.SHIFTFLAG,  
a.SITEFLAG,  
CrusherLoc  
FROM CrLoc, [sie].[CONOPS_SIE_SHIFT_INFO_V] a WITH (NOLOCK)  
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
  
  
  
