CREATE VIEW [MOR].[CONOPS_MOR_SP_AVG_PAYLOAD_V] AS
 
--select * from [mor].[CONOPS_MOR_SP_AVG_PAYLOAD_V] where shiftflag = 'curr'  
CREATE VIEW [mor].[CONOPS_MOR_SP_AVG_PAYLOAD_V]   
AS  
  
WITH CTE AS (
SELECT
	SiteFlag,
	ShiftId,
	Excav,
	AVG(FieldTons) AS AVG_PAYLOAD
FROM mor.shift_load_detail_v
GROUP BY
	SiteFlag,
	ShiftId,
	Excav
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
LEFT JOIN [mor].[CONOPS_MOR_SHOVEL_INFO_V] [s]
    ON [s].ShovelID = [sap].EXCAV
    AND [sap].shiftid = [s].shiftid
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


