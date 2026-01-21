CREATE VIEW [BAG].[CONOPS_BAG_SP_AVG_PAYLOAD_V] AS

--select * from [bag].[CONOPS_BAG_SP_AVG_PAYLOAD_V] where shiftflag = 'curr'  
CREATE VIEW [bag].[CONOPS_BAG_SP_AVG_PAYLOAD_V]   
AS  

WITH CTE AS (
SELECT
    b.SITEFLAG,
    b.shiftflag,
    b.SHIFTINDEX,
    SHOVEL_NAME AS EXCAV,
    AVG(MEASURED_PAYLOAD_SHORT_TONS) AS AVG_PAYLOAD,
    PayloadTarget AS Target
FROM BAG.FLEET_TRUCK_CYCLE_V a
RIGHT JOIN BAG.CONOPS_BAG_SHIFT_INFO_V b
    ON a.SHIFT_ID = b.SHIFTID
LEFT JOIN [dbo].[PAYLOAD_TARGET] [pt] WITH (NOLOCK) 
    ON [b].siteflag = [pt].siteflag
WHERE MEASURED_PAYLOAD_SHORT_TONS >= (SELECT PayloadFilterLower FROM dbo.PAYLOAD_FILTER WHERE SITEFLAG = 'BAG')
GROUP BY b.SITEFLAG, b.shiftflag, b.SHIFTINDEX, SHOVEL_NAME, PayloadTarget
)    
SELECT 
    [s].shiftflag,    
    [s].[siteflag],    
    [sap].EXCAV AS [ShovelID],    
    FLOOR(AVG([AVG_PAYLOAD])) AS [AVG_PAYLOAD],    
    [Target],    
    [s].[StatusName] AS [Status],    
    [s].[ReasonId],    
    [s].[ReasonDesc],    
    [s].[Operator],    
    [s].[OperatorImageURL]    
FROM CTE [sap]    
LEFT JOIN [BAG].[CONOPS_BAG_SHOVEL_INFO_V] [s]    
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



