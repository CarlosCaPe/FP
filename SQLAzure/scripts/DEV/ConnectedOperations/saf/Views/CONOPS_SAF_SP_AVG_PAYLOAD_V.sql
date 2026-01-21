CREATE VIEW [saf].[CONOPS_SAF_SP_AVG_PAYLOAD_V] AS

--select * from [saf].[CONOPS_SAF_SP_AVG_PAYLOAD_V] where shiftflag = 'curr'
CREATE VIEW [saf].[CONOPS_SAF_SP_AVG_PAYLOAD_V] 
AS

WITH CTE AS (
SELECT
	SiteFlag,
	ShiftId,
	Excav,
	AVG(FieldTons) AS AVG_PAYLOAD,
	AVG(FieldLSizeTons) AS PayloadTarget
FROM SAF.shift_load_detail_v
WHERE PayloadFilter = 1
GROUP BY
	SiteFlag,
	ShiftId,
	Excav
)

SELECT 
    [s].shiftflag,
    [s].[siteflag],
    [s].[ShovelID],
    FLOOR(AVG([Avg_Payload])) AS [Avg_Payload],
    [PayloadTarget] AS [Target],
    [s].[StatusName] AS [Status],
    [s].[ReasonId],
    [s].[ReasonDesc],
    [s].[Operator],
    [s].[OperatorImageURL]
FROM CTE [sap]
RIGHT JOIN [SAF].[CONOPS_SAF_SHOVEL_INFO_V] [s]
    ON [s].ShovelID = [sap].EXCAV
    AND [sap].shiftid = [s].shiftid
GROUP BY
    [s].shiftflag,
    [s].[siteflag],
    [s].[ShovelID],
    [sap].[PayloadTarget],
    [s].[StatusName],
    [s].[ReasonId],
    [s].[ReasonDesc],
    [s].[Operator],
    [s].[OperatorImageURL]

