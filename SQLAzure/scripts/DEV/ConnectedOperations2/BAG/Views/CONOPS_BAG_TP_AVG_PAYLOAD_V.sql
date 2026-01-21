CREATE VIEW [BAG].[CONOPS_BAG_TP_AVG_PAYLOAD_V] AS



--select * from [bag].[CONOPS_BAG_TP_AVG_PAYLOAD_V] WITH (NOLOCK) ORDER BY shiftflag, siteflag, TRUCK  
CREATE VIEW [bag].[CONOPS_BAG_TP_AVG_PAYLOAD_V]   
AS  
  
WITH CTE AS (  
SELECT
	SITE_CODE,
	SHIFT_ID AS SHIFTID,
	TRUCK_NAME AS TRUCK,
	COALESCE(AVG(MEASURED_PAYLOAD_SHORT_TONS),0) AS AVG_PAYLOAD
FROM BAG.FLEET_TRUCK_CYCLE_V
WHERE MEASURED_PAYLOAD_SHORT_TONS >= (SELECT PayloadFilterLower FROM dbo.PAYLOAD_FILTER WHERE SITEFLAG = 'BAG')
GROUP BY SITE_CODE, SHIFT_ID, TRUCK_NAME
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
LEFT JOIN [BAG].[CONOPS_BAG_TRUCK_DETAIL_V] [truck] WITH (NOLOCK)  
	ON [pl].TRUCK = [truck].TruckID AND [pl].SHIFTID = [truck].SHIFTID   
LEFT JOIN [dbo].[PAYLOAD_TARGET] [pt] WITH (NOLOCK) 
	ON [truck].siteflag = [pt].siteflag  
WHERE shiftflag is not null  


