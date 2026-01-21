CREATE VIEW [dbo].[CONOPS_LH_SP_AVG_PAYLOAD_V] AS


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

