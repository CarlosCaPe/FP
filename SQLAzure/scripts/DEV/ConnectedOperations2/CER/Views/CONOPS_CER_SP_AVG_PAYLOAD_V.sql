CREATE VIEW [CER].[CONOPS_CER_SP_AVG_PAYLOAD_V] AS


  
  
  
  
CREATE VIEW [cer].[CONOPS_CER_SP_AVG_PAYLOAD_V]  
AS  
  
WITH CTE AS (
SELECT 
    SHIFTINDEX,    
    SITE_CODE,    
    EXCAV,    
    AVG([load].MEASURETON) AS Avg_Payload  
    --264 AS [Target]    
FROM [dbo].[lh_load] [load] WITH (NOLOCK)    
WHERE [load].MEASURETON >= (SELECT PayloadFilterLower FROM dbo.PAYLOAD_FILTER WHERE SITEFLAG = 'CER')    
    AND SITE_CODE = 'CER'
GROUP BY SHIFTINDEX, SITE_CODE, EXCAV
)    
SELECT 
    [s].shiftflag,    
    [s].[siteflag],    
    [sap].EXCAV AS [ShovelID],    
    FLOOR(AVG([Avg_Payload])) AS [Avg_Payload],    
    ShovelPayloadTarget AS [Target],    
    [s].[StatusName] AS [Status],    
    [s].[ReasonId],    
    [s].[ReasonDesc],    
    [s].[Operator],    
    [s].[OperatorImageURL]    
FROM CTE [sap]    
LEFT JOIN [CER].[CONOPS_CER_SHOVEL_INFO_V] [s]    
    ON [s].ShovelID = [sap].EXCAV    
    AND [sap].shiftindex = [s].shiftindex     
LEFT JOIN [cer].[CONOPS_CER_SHOVEL_PAYLOAD_TARGET_V] pt  
    ON s.shiftid = pt.shiftid 
    AND s.ShovelID = pt.shovelid  
WHERE s.shiftflag IS NOT NULL    
GROUP BY     
    [s].shiftflag,    
    [s].[siteflag],    
    [sap].EXCAV,    
    ShovelPayloadTarget,    
    [s].[StatusName],    
    [s].[ReasonId],    
    [s].[ReasonDesc],    
    [s].[Operator],    
    [s].[OperatorImageURL]


