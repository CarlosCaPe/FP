CREATE VIEW [dbo].[CONOPS_LH_SP_AVG_PAYLOAD_V] AS



--select * from [dbo].[CONOPS_LH_SP_AVG_PAYLOAD_V] WITH (NOLOCK)
CREATE VIEW [dbo].[CONOPS_LH_SP_AVG_PAYLOAD_V]
AS

SELECT [sap].shiftflag,
	   [sap].[siteflag],
	   [sap].EXCAV [ShovelID],
	   FLOOR([AVG_Payload]) [AVG_Payload],
	   [Target],
	   [s].[StatusName] [Status],
	   [s].[ReasonId],
	   [s].[ReasonDesc],
	   [s].[Operator],
	   [s].[OperatorImageURL]
FROM [mor].[CONOPS_MOR_SP_AVG_PAYLOAD_V] [sap]
LEFT JOIN [mor].[CONOPS_MOR_SHOVEL_INFO_V] [s]
ON [s].ShovelID = [sap].EXCAV
   AND [sap].shiftflag = [s].shiftflag AND [sap].[siteflag] = [s].[siteflag]
WHERE [sap].[siteflag] = 'MOR'

UNION ALL

SELECT [sap].shiftflag,
	   [sap].[siteflag],
	   [sap].EXCAV [ShovelID],
	   FLOOR([AVG_Payload]) [AVG_Payload],
	   [Target],
	   [s].[StatusName] [Status],
	   [s].[ReasonId],
	   [s].[ReasonDesc],
	   [s].[Operator],
	   [s].[OperatorImageURL]
FROM [bag].[CONOPS_BAG_SP_AVG_PAYLOAD_V] [sap]
LEFT JOIN [bag].[CONOPS_BAG_SHOVEL_INFO_V] [s]
ON [s].ShovelID = [sap].EXCAV
   AND [sap].shiftflag = [s].shiftflag AND [sap].[siteflag] = [s].[siteflag]
WHERE [sap].[siteflag] = 'BAG'

UNION ALL

SELECT [sap].shiftflag,
	   [sap].[siteflag],
	   [sap].EXCAV [ShovelID],
	   FLOOR([AVG_Payload]) [AVG_Payload],
	   [Target],
	   [s].[StatusName] [Status],
	   [s].[ReasonId],
	   [s].[ReasonDesc],
	   [s].[Operator],
	   [s].[OperatorImageURL]
FROM [saf].[CONOPS_SAF_SP_AVG_PAYLOAD_V] [sap]
LEFT JOIN [bag].[CONOPS_BAG_SHOVEL_INFO_V] [s]
ON [s].ShovelID = [sap].EXCAV
   AND [sap].shiftflag = [s].shiftflag AND [sap].[siteflag] = [s].[siteflag]
WHERE [sap].[siteflag] = 'SAF'


UNION ALL

SELECT [sap].shiftflag,
	   [sap].[siteflag],
	   [sap].EXCAV [ShovelID],
	   FLOOR([AVG_Payload]) [AVG_Payload],
	   [Target],
	   [s].[StatusName] [Status],
	   [s].[ReasonId],
	   [s].[ReasonDesc],
	   [s].[Operator],
	   [s].[OperatorImageURL]
FROM [sie].[CONOPS_SIE_SP_AVG_PAYLOAD_V] [sap]
LEFT JOIN [sie].[CONOPS_SIE_SHOVEL_INFO_V] [s]
ON [s].ShovelID = [sap].EXCAV
   AND [sap].shiftflag = [s].shiftflag AND [sap].[siteflag] = [s].[siteflag]
WHERE [sap].[siteflag] = 'SIE'


UNION ALL

SELECT [sap].shiftflag,
	   [sap].[siteflag],
	   [sap].EXCAV [ShovelID],
	   FLOOR([AVG_Payload]) [AVG_Payload],
	   [Target],
	   [s].[StatusName] [Status],
	   [s].[ReasonId],
	   [s].[ReasonDesc],
	   [s].[Operator],
	   [s].[OperatorImageURL]
FROM [cli].[CONOPS_CLI_SP_AVG_PAYLOAD_V] [sap]
LEFT JOIN [cli].[CONOPS_CLI_SHOVEL_INFO_V] [s]
ON [s].ShovelID = [sap].EXCAV
   AND [sap].shiftflag = [s].shiftflag AND [sap].[siteflag] = [s].[siteflag]
WHERE [sap].[siteflag] = 'CMX'

UNION ALL

SELECT [sap].shiftflag,
	   [sap].[siteflag],
	   [sap].EXCAV [ShovelID],
	   FLOOR([AVG_Payload]) [AVG_Payload],
	   [Target],
	   [s].[StatusName] [Status],
	   [s].[ReasonId],
	   [s].[ReasonDesc],
	   [s].[Operator],
	   [s].[OperatorImageURL]
FROM [chi].[CONOPS_CHI_SP_AVG_PAYLOAD_V] [sap]
LEFT JOIN [chi].[CONOPS_CHI_SHOVEL_INFO_V] [s]
ON [s].ShovelID = [sap].EXCAV
   AND [sap].shiftflag = [s].shiftflag AND [sap].[siteflag] = [s].[siteflag]
WHERE [sap].[siteflag] = 'CHI'


UNION ALL

SELECT [sap].shiftflag,
	   [sap].[siteflag],
	   [sap].EXCAV [ShovelID],
	   FLOOR([AVG_Payload]) [AVG_Payload],
	   [Target],
	   [s].[StatusName] [Status],
	   [s].[ReasonId],
	   [s].[ReasonDesc],
	   [s].[Operator],
	   [s].[OperatorImageURL]
FROM [cer].[CONOPS_CER_SP_AVG_PAYLOAD_V] [sap]
LEFT JOIN [cer].[CONOPS_CER_SHOVEL_INFO_V] [s]
ON [s].ShovelID = [sap].EXCAV
   AND [sap].shiftflag = [s].shiftflag AND [sap].[siteflag] = [s].[siteflag]
WHERE [sap].[siteflag] = 'CER'

