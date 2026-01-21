CREATE VIEW [BAG].[CONOPS_BAG_DAILY_TP_AVG_PAYLOAD_V] AS

--select * from [bag].[CONOPS_BAG_DAILY_TP_AVG_PAYLOAD_V] WITH (NOLOCK) ORDER BY shiftflag, siteflag, TRUCK
CREATE VIEW [bag].[CONOPS_BAG_DAILY_TP_AVG_PAYLOAD_V] 
AS

WITH CTE AS (
SELECT
	SITE_CODE,
	SHIFT_ID AS SHIFTID,
	TRUCK_NAME AS TRUCK,
	COALESCE(AVG(MEASURED_PAYLOAD_SHORT_TONS),0) AS AVG_PAYLOAD,
	AVG(REPORT_PAYLOAD_SHORT_TONS) AS PayloadTarget
FROM BAG.FLEET_SHOVEL_CYCLE_V a
WHERE PayloadFilter = 1
GROUP BY
	SITE_CODE,
	SHIFT_ID,
	TRUCK_NAME
) 

SELECT
	shiftflag,
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
RIGHT JOIN [BAG].[CONOPS_BAG_DAILY_TRUCK_DETAIL_V] [truck] WITH (NOLOCK)
	ON [pl].TRUCK = [truck].TruckID
	AND [pl].SHIFTID = [truck].SHIFTID 

