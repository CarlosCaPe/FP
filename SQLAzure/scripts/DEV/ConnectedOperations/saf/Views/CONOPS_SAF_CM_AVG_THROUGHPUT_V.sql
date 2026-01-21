CREATE VIEW [saf].[CONOPS_SAF_CM_AVG_THROUGHPUT_V] AS
  
  
  
  
  
  
-- SELECT * FROM [saf].[CONOPS_SAF_CM_AVG_THROUGHPUT_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'PREV'    
CREATE VIEW [saf].[CONOPS_SAF_CM_AVG_THROUGHPUT_V]    
AS    
  
WITH ShiftAvg AS (  
 SELECT ShiftIndex  
  ,SiteFlag  
  ,CrusherLoc  
  ,AVG(SensorValue) SensorValue
  --,ROW_NUMBER() OVER (PARTITION BY ShiftIndex, CrusherLoc ORDER BY Hr DESC) AS Rn  
  --,Hr  
 FROM [saf].[CONOPS_SAF_CM_HOURLY_CRUSHER_THROUGHPUT_V] WITH (NOLOCK)  
 GROUP BY ShiftIndex,SiteFlag,CrusherLoc
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
 FROM [saf].[CONOPS_SAF_CM_HOURLY_CRUSHER_THROUGHPUT_V] [hct] WITH (NOLOCK)  
 LEFT JOIN ShiftAvg [sa]  
  ON [hct].ShiftIndex = [sa].ShiftIndex  
  AND [hct].CrusherLoc = [sa].CrusherLoc  
) [ht]  
WHERE [ht].Rn = 1  
  
  
