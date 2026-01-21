CREATE VIEW [CER].[CONOPS_CER_TP_AVG_PAYLOAD_V] AS

  
  
CREATE VIEW [cer].[CONOPS_CER_TP_AVG_PAYLOAD_V]  
AS  
  
WITH CTE AS (  
SELECT SHIFTINDEX,  
    TRUCK,  
    [Operator],  
    OperatorImageURL,  
    COALESCE([AVG_Payload], 0) [AVG_Payload]  
    --264 [Target]  
FROM (  
 SELECT  [payload].SHIFTINDEX,  
   [payload].SITE_CODE,  
   [t].FieldId [TRUCK],  
   COALESCE([w].FieldName, 'NONE') AS [Operator],  
   CASE WHEN [opm].[Personnel_Id] IS NULL OR [opm].[Personnel_Id] = -1 THEN NULL  
       ELSE concat([img].[value],  
          RIGHT('0000000000' + [opm].[Personnel_Id], 10),'.jpg') END as OperatorImageURL,  
   AVG([payload].MEASURETON) [AVG_Payload]  
 FROM [CER].[pit_truck_c] (NOLOCK) [t]  
 LEFT JOIN [dbo].[lh_load] (NOLOCK) [payload]  
 ON [payload].TRUCK = [t].FieldId  
 AND [payload].SHIFTINDEX = [t].SHIFTINDEX  
 LEFT JOIN [CER].[pit_worker] [w] WITH (NOLOCK)  
 ON [w].Id = [t].FieldCuroper  
 LEFT JOIN [cer].[operator_personnel_map] [opm] WITH (NOLOCK) 
 ON [w].FieldId = [opm].[Operator_Id]
 LEFT JOIN [dbo].LOOKUPS [img] WITH (NOLOCK)
 ON img.TableType = 'CONF'
 AND img.TableCode = 'IMGURL'
 WHERE [payload].SITE_CODE = 'CER'  
    AND [payload].MEASURETON >= (SELECT PayloadFilterLower FROM dbo.PAYLOAD_FILTER WHERE SITEFLAG = 'CER') 
 GROUP BY [payload].SHIFTINDEX,[payload]. SITE_CODE, [t].FieldId, [w].FieldName, [opm].[Personnel_Id], [img].[value]
 )main  
)   
  
SELECT truck.shiftflag,  
    truck.siteflag,  
    [truck].SHIFTINDEX,  
    TRUCK,  
    UPPER([pl].Operator) as Operator,  
    [pl].OperatorImageURL,  
    [AVG_Payload],  
    CASE WHEN truckid LIKE 'C1%' THEN '245'  
  WHEN truckid LIKE 'C3%' THEN '300'  
  WHEN truckid LIKE 'C4%' THEN '381'  
  WHEN truckid LIKE 'C5%' THEN '380' END AS [target],  
    StatusName [Status],  
    [truck].ReasonId,  
    [truck].ReasonDesc,  
    [truck].Location  
FROM cte [pl] WITH (NOLOCK)  
LEFT JOIN [CER].[CONOPS_CER_TRUCK_DETAIL_V] [truck] WITH (NOLOCK)  
ON [pl].TRUCK = [truck].TruckID AND [pl].SHIFTINDEX = [truck].SHIFTINDEX   
  
WHERE truck.shiftflag is not null  
  
  

