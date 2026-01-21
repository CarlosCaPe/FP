CREATE VIEW [TYR].[CONOPS_TYR_DAILY_TP_AVG_PAYLOAD_V] AS




  
    
--select * from [tyr].[CONOPS_TYR_DAILY_TP_AVG_PAYLOAD_V] WITH (NOLOCK) where shiftflag = 'curr'  ORDER BY shiftflag, siteflag, TRUCK      
CREATE VIEW [TYR].[CONOPS_TYR_DAILY_TP_AVG_PAYLOAD_V]       
AS      
      
WITH CTE AS (      
SELECT SHIFTINDEX,      
    TRUCK,         
    COALESCE([AVG_Payload], 0) [AVG_Payload]   
FROM (      
 SELECT  [payload].SHIFTINDEX,      
   [payload].SITE_CODE,      
   [t].FieldId [TRUCK],      
   COALESCE([w].FieldName, 'NONE') AS [Operator],        
   AVG([payload].MEASURETON) [AVG_Payload]      
 FROM [tyr].[pit_truck_c] (NOLOCK) [t]      
 LEFT JOIN [dbo].[lh_load] (NOLOCK) [payload]      
 ON [payload].TRUCK = [t].FieldId      
 AND [payload].SHIFTINDEX = [t].SHIFTINDEX      
 LEFT JOIN [tyr].[pit_worker] [w] WITH (NOLOCK)      
 ON [w].Id = [t].FieldCuroper      
 WHERE [payload].SITE_CODE = 'TYR'      
    AND [payload].MEASURETON >= (SELECT PayloadFilterLower FROM dbo.PAYLOAD_FILTER WHERE SITEFLAG = 'TYR')    
 GROUP BY [payload].SHIFTINDEX,[payload]. SITE_CODE, [t].FieldId, [w].FieldName, [w].FieldId      
 )main      
)       
      
SELECT shiftflag,      
    [truck].siteflag,      
    [truck].SHIFTINDEX,      
    TRUCK,      
    UPPER(Operator) as Operator,      
    OperatorImageURL,      
    [AVG_Payload],      
    --ROUND([AVG_Payload],0) [AVG_Payload],      
    [PayloadTarget] [Target],      
    StatusName [Status],      
    [truck].ReasonId,      
    [truck].ReasonDesc,      
    [truck].Location      
FROM cte [pl] WITH (NOLOCK)      
LEFT JOIN [tyr].[CONOPS_TYR_DAILY_TRUCK_DETAIL_V] [truck] WITH (NOLOCK)      
ON [pl].TRUCK = [truck].TruckID AND [pl].SHIFTINDEX = [truck].SHIFTINDEX   
LEFT JOIN [dbo].[PAYLOAD_TARGET] [pt] WITH (NOLOCK) ON [truck].siteflag = [pt].siteflag    
      
WHERE shiftflag is not null   
    
  


