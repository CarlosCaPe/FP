CREATE VIEW [CLI].[CONOPS_CLI_TP_AVG_PAYLOAD_V] AS

  
 
--select * from [cli].[CONOPS_CLI_TP_AVG_PAYLOAD_V] WITH (NOLOCK) ORDER BY shiftflag, siteflag, TRUCK  
CREATE VIEW [cli].[CONOPS_CLI_TP_AVG_PAYLOAD_V]   
AS  
  
WITH CTE AS (  
SELECT SHIFTINDEX,  
    TRUCK,  
    [Operator],  
    OperatorImageURL,  
    COALESCE([AVG_Payload], 0) [AVG_Payload]
FROM (  
 SELECT  [payload].SHIFTINDEX,  
   [payload].SITE_CODE,  
   [t].FieldId [TRUCK],  
   COALESCE([w].FieldName, 'NONE') AS [Operator],  
   CASE WHEN [w].FieldId IS NULL OR [w].FieldId = -1 THEN NULL  
       ELSE concat([img].[value],  
          RIGHT('0000000000' + [w].FieldId, 10),'.jpg') END as OperatorImageURL,  
   AVG([payload].MEASURETON) [AVG_Payload]  
 FROM [CLI].[pit_truck_c] (NOLOCK) [t]  
 LEFT JOIN [dbo].[lh_load] (NOLOCK) [payload]  
 ON [payload].TRUCK = [t].FieldId  
 AND [payload].SHIFTINDEX = [t].SHIFTINDEX  
 LEFT JOIN [CLI].[pit_worker] [w] WITH (NOLOCK)  
 ON [w].Id = [t].FieldCuroper  
 LEFT JOIN [dbo].LOOKUPS [img] WITH (NOLOCK)
 ON img.TableType = 'CONF'
 AND img.TableCode = 'IMGURL'
 WHERE [payload].SITE_CODE = 'CLI'  
    AND [payload].MEASURETON >= (SELECT PayloadFilterLower FROM dbo.PAYLOAD_FILTER WHERE SITEFLAG = 'CLI') 
 GROUP BY [payload].SHIFTINDEX,[payload]. SITE_CODE, [t].FieldId, [w].FieldName, [w].FieldId,[img].[value]  
 )main  
)   
  
SELECT shiftflag,  
    [truck].siteflag,  
    [truck].SHIFTINDEX,  
    TRUCK,  
    UPPER([pl].Operator) as Operator,  
    [pl].OperatorImageURL,  
    [AVG_Payload],  
    pt.PayloadTarget AS [Target],  
    StatusName [Status],  
    [truck].ReasonId,  
    [truck].ReasonDesc,  
    [truck].Location  
FROM cte [pl] WITH (NOLOCK)  
LEFT JOIN [CLI].[CONOPS_CLI_TRUCK_DETAIL_V] [truck] WITH (NOLOCK)  
ON [pl].TRUCK = [truck].TruckID AND [pl].SHIFTINDEX = [truck].SHIFTINDEX   
LEFT JOIN dbo.PAYLOAD_TARGET pt WITH (NOLOCK) ON [truck].siteflag = pt.Siteflag
WHERE shiftflag is not null  
  
  
  
  

