CREATE VIEW [MOR].[CONOPS_MOR_CM_CR2Mill_V] AS





--SELECT * FROM [mor].[CONOPS_MOR_CM_CR2Mill_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [mor].[CONOPS_MOR_CM_CR2Mill_V]  
AS  

WITH CTE AS (
SELECT 
shiftindex,
COMPONENT,
[SENSOR_VALUE],
ROW_NUMBER() OVER (PARTITION BY SHIFTINDEX,COMPONENT ORDER BY VALUE_TS DESC) NUM  
FROM [dbo].[CR2_MILL]
WHERE SITEFLAG = 'MOR'),

CR2Mill AS (
SELECT 
[SHIFTINDEX],
CrusherCR2ToMill,
CrusherMFLIOS,
CrusherMillIOS
FROM (
SELECT 
[SHIFTINDEX]
,[COMPONENT]
,CASE WHEN ISNUMERIC([SENSOR_VALUE]) = 1 THEN CAST([SENSOR_VALUE] AS float)
ELSE 0 END AS [SENSOR_VALUE]
FROM CTE WITH (NOLOCK)
WHERE NUM = 1) src
PIVOT
(AVG([SENSOR_VALUE]) FOR [COMPONENT]  IN (CrusherCR2ToMill, CrusherMFLIOS, CrusherMillIOS)) AS PivotTable
),

Final AS (
SELECT 
a.[SITEFLAG]
,a.[SHIFTFLAG]
,CrusherCR2ToMill
,CrusherMFLIOS
,CrusherMillIOS
FROM [mor].[CONOPS_MOR_SHIFT_INFO_V] a WITH (NOLOCK)
LEFT JOIN CR2Mill [is] WITH (NOLOCK)
ON a.SHIFTINDEX = [is].SHIFTINDEX)

SELECT
Siteflag,
Shiftflag,
CASE WHEN Crusher like '%MFL%' THEN 'Crusher 2' ELSE 'Crusher 3' END AS CrusherLoc,
Crusher,
CR2Mill
FROM Final
CROSS APPLY (VALUES ('CR2ToMill', CrusherCR2ToMill),
					('MFLIOS', CrusherMFLIOS),
					('MillIOS', CrusherMillIOS))
CrossApplied (Crusher, CR2Mill)




