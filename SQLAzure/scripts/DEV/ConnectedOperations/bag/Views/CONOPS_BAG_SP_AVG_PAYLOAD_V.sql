CREATE VIEW [bag].[CONOPS_BAG_SP_AVG_PAYLOAD_V] AS

--select * from [bag].[CONOPS_BAG_SP_AVG_PAYLOAD_V] where shiftflag = 'curr'
CREATE VIEW [bag].[CONOPS_BAG_SP_AVG_PAYLOAD_V] 
AS

WITH CTE AS (
SELECT
	SITE_CODE,
	SHIFT_ID AS SHIFTID,
	SHOVEL_NAME AS EXCAV,
	AVG(MEASURED_PAYLOAD_SHORT_TONS) AS AVG_PAYLOAD,
	AVG(REPORT_PAYLOAD_SHORT_TONS) AS Target
FROM BAG.FLEET_SHOVEL_CYCLE_V
WHERE PayloadFilter = 1
GROUP BY
	SITE_CODE,
	SHIFT_ID,
	SHOVEL_NAME
)

SELECT 
	[s].shiftflag,
	[s].[siteflag],
	[s].[ShovelID],
	FLOOR(AVG([AVG_PAYLOAD])) AS [AVG_PAYLOAD],
	[Target],
	[s].[StatusName] AS [Status],
	[s].[ReasonId],
	[s].[ReasonDesc],
	[s].[Operator],
	[s].[OperatorImageURL]
FROM CTE [sap]
RIGHT JOIN [BAG].[CONOPS_BAG_SHOVEL_INFO_V] [s]
	ON [s].ShovelID = [sap].EXCAV
	AND [sap].SHIFTID = [s].shiftid 
GROUP BY 
	[s].shiftflag,
	[s].[siteflag],
	[s].[ShovelID],
	[Target],
	[s].[StatusName],
	[s].[ReasonId],
	[s].[ReasonDesc],
	[s].[Operator],
	[s].[OperatorImageURL]

