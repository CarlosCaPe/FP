CREATE VIEW [BAG].[CONOPS_BAG_OVERALL_AVG_PAYLOAD_V] AS



--select * from [bag].[CONOPS_BAG_OVERALL_AVG_PAYLOAD_V] where shiftflag = 'curr'  
CREATE VIEW [bag].[CONOPS_BAG_OVERALL_AVG_PAYLOAD_V]   
AS  
  
SELECT [shift].shiftflag,  
    [shift].[siteflag],  
    COALESCE([AVG_Payload], 0) [AVG_Payload],  
    [PayloadTarget] [Target]  
FROM [BAG].[CONOPS_BAG_SHIFT_INFO_V] [shift]  
LEFT JOIN (  
 SELECT
	SITE_CODE,
	SHIFT_ID AS SHIFTID,
	AVG(MEASURED_PAYLOAD_SHORT_TONS) AS AVG_PAYLOAD
FROM BAG.FLEET_TRUCK_CYCLE_V
WHERE MEASURED_PAYLOAD_SHORT_TONS >= (SELECT PayloadFilterLower FROM dbo.PAYLOAD_FILTER WHERE SITEFLAG = 'BAG')
GROUP BY SITE_CODE, SHIFT_ID
) [AvgPayload]  
on [AvgPayload].SHIFTID = [shift].SHIFTID   
LEFT JOIN [dbo].[PAYLOAD_TARGET] [pt] WITH (NOLOCK) ON [shift].siteflag = [pt].siteflag  
  





