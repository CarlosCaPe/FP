CREATE VIEW [CHI].[CONOPS_CHI_OVERALL_AVG_PAYLOAD_V] AS

  
  
--select * from [chi].[CONOPS_CHI_OVERALL_AVG_PAYLOAD_V] where shiftflag = 'curr'  
CREATE VIEW [chi].[CONOPS_CHI_OVERALL_AVG_PAYLOAD_V]   
AS  
  
SELECT [shift].shiftflag,  
    [shift].[siteflag],  
    COALESCE([AVG_Payload], 0) [AVG_Payload],  
    [pt].PayloadTarget [Target]  
FROM [CHI].[CONOPS_CHI_SHIFT_INFO_V] [shift]  
LEFT JOIN (  
 SELECT SHIFTINDEX,  
     SITE_CODE,  
     AVG([load].MEASURETON) Avg_Payload  
 FROM [dbo].[lh_load] [load] WITH (NOLOCK)  
 WHERE [load].MEASURETON >= (SELECT PayloadFilterLower FROM dbo.PAYLOAD_FILTER WHERE SITEFLAG = 'CHI') 
 AND SITE_CODE = 'CHI'  
 GROUP BY SHIFTINDEX, SITE_CODE  
) [AvgPayload]  
on [AvgPayload].SHIFTINDEX = [shift].ShiftIndex  
AND [AvgPayload].SITE_CODE = [shift].[siteflag]  
LEFT JOIN [dbo].[PAYLOAD_TARGET] [pt] WITH (NOLOCK) ON [shift].siteflag = [pt].siteflag  
  
  

