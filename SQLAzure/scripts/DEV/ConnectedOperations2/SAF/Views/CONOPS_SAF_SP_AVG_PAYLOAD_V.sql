CREATE VIEW [SAF].[CONOPS_SAF_SP_AVG_PAYLOAD_V] AS


  
  
--select * from [saf].[CONOPS_SAF_SP_AVG_PAYLOAD_V] where shiftflag = 'curr'  
CREATE VIEW [saf].[CONOPS_SAF_SP_AVG_PAYLOAD_V]   
AS  
  
WITH CTE AS (
SELECT 
    SHIFTINDEX,    
    SITE_CODE,    
    EXCAV,    
    AVG([load].MEASURETON) AS Avg_Payload  
FROM [dbo].[lh_load] [load] WITH (NOLOCK)    
WHERE [load].MEASURETON >= (SELECT PayloadFilterLower FROM dbo.PAYLOAD_FILTER WHERE SITEFLAG = 'SAF')  
    AND SITE_CODE = 'SAF'
GROUP BY SHIFTINDEX, SITE_CODE, EXCAV
)    
SELECT 
    [s].shiftflag,    
    [s].[siteflag],    
    [sap].EXCAV AS [ShovelID],    
    FLOOR(AVG([Avg_Payload])) AS [Avg_Payload],    
    [pt].[PayloadTarget] AS [Target],    
    [s].[StatusName] AS [Status],    
    [s].[ReasonId],    
    [s].[ReasonDesc],    
    [s].[Operator],    
    [s].[OperatorImageURL]    
FROM CTE [sap]    
LEFT JOIN [SAF].[CONOPS_SAF_SHOVEL_INFO_V] [s]    
    ON [s].ShovelID = [sap].EXCAV    
    AND [sap].shiftindex = [s].shiftindex  
LEFT JOIN [dbo].[PAYLOAD_TARGET] [pt] WITH (NOLOCK)
    ON [s].siteflag = [pt].[Siteflag]
WHERE s.shiftflag IS NOT NULL    
GROUP BY     
    [s].shiftflag,    
    [s].[siteflag],    
    [sap].EXCAV,    
    [pt].[PayloadTarget],    
    [s].[StatusName],    
    [s].[ReasonId],    
    [s].[ReasonDesc],    
    [s].[Operator],    
    [s].[OperatorImageURL]


