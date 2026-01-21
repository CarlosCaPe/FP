CREATE VIEW [BAG].[CONOPS_BAG_CM_AVG_THROUGHPUT_V] AS






-- SELECT * FROM [bag].[CONOPS_BAG_CM_AVG_THROUGHPUT_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'PREV'  
CREATE VIEW [bag].[CONOPS_BAG_CM_AVG_THROUGHPUT_V]  
AS  

WITH ShiftAvg AS (
	SELECT ShiftIndex
		,SiteFlag
		,CrusherLoc
		,SensorValue
		,ROW_NUMBER() OVER (PARTITION BY ShiftIndex, CrusherLoc ORDER BY Hr DESC) AS Rn
		,Hr
	FROM [bag].[CONOPS_BAG_CM_HOURLY_CRUSHER_THROUGHPUT_V] WITH (NOLOCK)
)

SELECT [ht].ShiftIndex
	,[ht].ShiftFlag
	,[ht].SiteFlag
	,[ht].CrusherLoc
	,HrAvgThroughput
	,ShfAvgThroughput
FROM ( 
	SELECT [hct].ShiftIndex
		,[hct].ShiftFlag
		,[hct].SiteFlag
		,[hct].CrusherLoc
		,[hct].SensorValue AS HrAvgThroughput
		,[sa].SensorValue AS ShfAvgThroughput
		,ROW_NUMBER() OVER (PARTITION BY [hct].ShiftIndex, [hct].CrusherLoc ORDER BY [hct].Hr DESC) AS Rn
	FROM [bag].[CONOPS_BAG_CM_HOURLY_CRUSHER_THROUGHPUT_V] [hct] WITH (NOLOCK)
	LEFT JOIN ShiftAvg [sa]
		ON [hct].ShiftIndex = [sa].ShiftIndex
		AND [hct].CrusherLoc = [sa].CrusherLoc
) [ht]
WHERE [ht].Rn = 1


