CREATE VIEW [ABR].[CONOPS_ABR_CM_HOURLY_CRUSHER_THROUGHPUT_V] AS




-- SELECT * FROM [abr].[CONOPS_ABR_CM_HOURLY_CRUSHER_THROUGHPUT_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'CURR'  
CREATE VIEW [ABR].[CONOPS_ABR_CM_HOURLY_CRUSHER_THROUGHPUT_V]  
AS  

WITH CteShiftInfo AS (
	SELECT ShiftIndex
		,ShiftFlag
		,SiteFlag
		,ShiftStartDatetime
	FROM [abr].[CONOPS_ABR_SHIFT_INFO_V] WITH (NOLOCK)
),

CTEThroughput AS (
	SELECT ShiftIndex
		,SiteFlag
		,Value_Ts
		,CrusherLoc
		,SensorValue
	FROM [ConnectedOperations].[dbo].[CRUSHER_THROUGHPUT] WITH (NOLOCK)
	WHERE SiteFlag = 'ELA'
),

Throughput AS (
	SELECT [tp].ShiftIndex
		,[tp].ShiftFlag
		,[tp].SiteFlag
		,[tp].CrusherLoc
		,(CASE WHEN [tp].SensorValue > 0 THEN [tp].SensorValue ELSE 0 END) AS SensorValue
		,DATEADD(hh, IIF([tp].HOS = 0, 0, [tp].HOS -1), [tp].ShiftStartDateTime) AS Hr
		,IIF([tp].HOS = 0, 1, [tp].HOS) AS HOS
	FROM (
		SELECT [csi].ShiftIndex
			,[csi].ShiftFlag
			,[csi].SiteFlag
			,[cct].Value_Ts
			,[cct].CrusherLoc
			,(CASE WHEN [cct].SensorValue < 0 THEN 0 ELSE [cct].SensorValue END) AS SensorValue
			,[csi].ShiftStartDateTime
			,CEILING(DATEDIFF(MINUTE, [csi].ShiftStartDateTime, [cct].Value_Ts) / 60.00) as HOS
		FROM CteShiftInfo [csi]
		LEFT JOIN CTEThroughput [cct]
			ON [csi].ShiftIndex = [cct].ShiftIndex
			AND [csi].SiteFlag = [cct].SiteFlag
	) [tp]
)

SELECT ShiftIndex
	,ShiftFlag
	,SiteFlag
	,CrusherLoc
	,COALESCE(AVG(SensorValue), 0) AS SensorValue
	,Hr
	,Hos
FROM Throughput
GROUP BY ShiftIndex, SiteFlag, ShiftFlag, CrusherLoc, Hos, Hr


