CREATE VIEW [SAF].[CONOPS_SAF_DAILY_TP_AVG_PAYLOAD_V] AS

  
    
    
    
--select * from [saf].[CONOPS_SAF_DAILY_TP_AVG_PAYLOAD_V] WITH (NOLOCK) ORDER BY shiftflag, siteflag, TRUCK    
CREATE VIEW [saf].[CONOPS_SAF_DAILY_TP_AVG_PAYLOAD_V]     
AS    
    
WITH CTE AS (    
SELECT SHIFTINDEX,    
    TRUCK,    
    --[Operator],    
    --OperatorImageURL,    
    COALESCE([AVG_Payload], 0) [AVG_Payload]    
    --264 [Target]    
FROM (    
 SELECT  [payload].SHIFTINDEX,    
   [payload].SITE_CODE,    
   [t].FieldId [TRUCK],    
   COALESCE([w].FieldName, 'NONE') AS [Operator],    
   /*CASE WHEN [w].FieldId IS NULL OR [w].FieldId = -1 THEN NULL    
       ELSE concat('https://images.services-tst.fmi.com/publishedimages/',    
          RIGHT('0000000000' + [w].FieldId, 10),'.jpg') END as OperatorImageURL,  */  
   AVG([payload].MEASURETON) [AVG_Payload]    
 FROM [SAF].[pit_truck_c] (NOLOCK) [t]    
 LEFT JOIN [dbo].[lh_load] (NOLOCK) [payload]    
 ON [payload].TRUCK = [t].FieldId    
 AND [payload].SHIFTINDEX = [t].SHIFTINDEX    
 LEFT JOIN [SAF].[pit_worker] [w] WITH (NOLOCK)    
 ON [w].Id = [t].FieldCuroper    
 WHERE [payload].SITE_CODE = 'SAF'    
    AND [payload].MEASURETON >= (SELECT PayloadFilterLower FROM dbo.PAYLOAD_FILTER WHERE SITEFLAG = 'SAF')
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
    [PayloadTarget] [Target],    
    StatusName [Status],    
    [truck].ReasonId,    
    [truck].ReasonDesc,    
    [truck].Location    
FROM cte [pl] WITH (NOLOCK)    
LEFT JOIN [SAF].[CONOPS_SAF_DAILY_TRUCK_DETAIL_V] [truck] WITH (NOLOCK)    
ON [pl].TRUCK = [truck].TruckID AND [pl].SHIFTINDEX = [truck].SHIFTINDEX     
LEFT JOIN [dbo].[PAYLOAD_TARGET] [pt] WITH (NOLOCK) ON [truck].siteflag = [pt].siteflag    
    
WHERE shiftflag is not null    
    
    
    
  

