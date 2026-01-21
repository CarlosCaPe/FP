CREATE VIEW [TYR].[CONOPS_TYR_SP_AVG_PAYLOAD_V] AS



--select * from [tyr].[CONOPS_TYR_SP_AVG_PAYLOAD_V] where shiftflag = 'curr'  
CREATE VIEW [TYR].[CONOPS_TYR_SP_AVG_PAYLOAD_V]   
AS  

WITH CTE AS (
SELECT 
    SHIFTINDEX,    
    EXCAV,    
    AVG([load].MEASURETON) AS Avg_Payload,    
    [PayloadTarget] AS [Target]    
FROM [dbo].[lh_load] [load] WITH (NOLOCK)
LEFT JOIN [dbo].[PAYLOAD_TARGET] [pt] WITH (NOLOCK) 
    ON [load].SITE_CODE = [pt].siteflag
WHERE [load].MEASURETON >= (SELECT PayloadFilterLower FROM dbo.PAYLOAD_FILTER WHERE SITEFLAG = 'TYR') 
    AND [load].SITE_CODE = 'TYR'
GROUP BY SHIFTINDEX, EXCAV, [PayloadTarget]
)    
SELECT 
    [s].shiftflag,    
    [s].[siteflag],    
    [sap].EXCAV AS [ShovelID],    
    FLOOR(AVG([Avg_Payload])) AS [Avg_Payload],    
    [Target],    
    [s].[StatusName] AS [Status],    
    [s].[ReasonId],    
    [s].[ReasonDesc],    
    [s].[Operator],    
    [s].[OperatorImageURL]    
FROM CTE [sap]    
LEFT JOIN [tyr].[CONOPS_TYR_SHOVEL_INFO_V] [s]    
    ON [s].ShovelID = [sap].EXCAV    
    AND [sap].shiftindex = [s].shiftindex     
WHERE s.shiftflag IS NOT NULL    
GROUP BY     
    [s].shiftflag,    
    [s].[siteflag],    
    [sap].EXCAV,    
    [Target],    
    [s].[StatusName],    
    [s].[ReasonId],    
    [s].[ReasonDesc],    
    [s].[Operator],    
    [s].[OperatorImageURL]


