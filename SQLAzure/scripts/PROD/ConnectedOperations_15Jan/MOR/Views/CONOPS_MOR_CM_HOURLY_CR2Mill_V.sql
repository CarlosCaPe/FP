CREATE VIEW [MOR].[CONOPS_MOR_CM_HOURLY_CR2Mill_V] AS





--SELECT * FROM [mor].[CONOPS_MOR_CM_HOURLY_CR2Mill_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [mor].[CONOPS_MOR_CM_HOURLY_CR2Mill_V]  
AS  

WITH CTE AS (
SELECT 
shiftindex,
COMPONENT,
[SENSOR_VALUE],
CASE WHEN DATEPART(MINUTE,VALUE_TS) = '15' THEN VALUE_TS END AS TimeInHour
FROM [dbo].[CR2_MILL]
WHERE SITEFLAG = 'MOR'),

CR2Mill AS (
SELECT 
[SHIFTINDEX],
CrusherCR2ToMill,
CrusherMFLIOS,
CrusherMillIOS,
TimeInHour
FROM (
SELECT 
[SHIFTINDEX]
,[COMPONENT]
,CASE WHEN ISNUMERIC([SENSOR_VALUE]) = 1 THEN CAST([SENSOR_VALUE] AS float)
ELSE 0 END AS [SENSOR_VALUE]
,DATEADD(MINUTE, DATEDIFF(MINUTE, 0, TimeInHour), 0) AS TimeInHour
FROM CTE WITH (NOLOCK)
WHERE TimeInHour IS NOT NULL) src
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
,TimeInHour
FROM [mor].[CONOPS_MOR_SHIFT_INFO_V] a WITH (NOLOCK)
LEFT JOIN CR2Mill [is] WITH (NOLOCK)
ON a.SHIFTINDEX = [is].SHIFTINDEX)

SELECT
Siteflag,
Shiftflag,
CASE WHEN Crusher like '%MFL%' THEN 'Crusher 2' ELSE 'Crusher 3' END AS CrusherLoc,
Crusher,
CR2Mill,
TimeinHour
FROM Final
CROSS APPLY (VALUES ('CrusherCR2ToMill', CrusherCR2ToMill),
					('CrusherMFLIOS', CrusherMFLIOS),
					('CrusherMillIOS', CrusherMillIOS))
CrossApplied (Crusher, CR2Mill)




