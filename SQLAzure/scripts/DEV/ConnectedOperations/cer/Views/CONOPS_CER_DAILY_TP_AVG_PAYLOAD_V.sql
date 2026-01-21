CREATE VIEW [cer].[CONOPS_CER_DAILY_TP_AVG_PAYLOAD_V] AS

--SELECT * FROM CER.CONOPS_CER_DAILY_TP_AVG_PAYLOAD_V
CREATE VIEW [cer].[CONOPS_CER_DAILY_TP_AVG_PAYLOAD_V]
AS

WITH CTE AS (
SELECT
	SiteFlag,
	ShiftId,
	Truck,
	AVG(FieldTons) AS AVG_PAYLOAD,
	AVG(FieldLSizetons) AS PayloadTarget
FROM CER.SHIFT_LOAD_DETAIL_V
WHERE PayloadFilter = 1
GROUP BY SiteFlag, ShiftId, Truck
) 

SELECT 
	shiftflag,
	[truck].siteflag,
	[truck].SHIFTINDEX,
	[truck].TruckID AS TRUCK,
	UPPER([truck].Operator) as Operator,
	CASE WHEN Truck.OperatorId IS NULL OR Truck.OperatorId = -1 
		THEN NULL
		ELSE concat(img.[value], RIGHT('0000000000' + truck.OperatorId, 10),'.jpg') END as OperatorImageURL, 
	[AVG_Payload],
	PayloadTarget AS [Target],
	StatusName [Status],
	[truck].ReasonId,
	[truck].ReasonDesc,
	[truck].Location
FROM cte [pl] WITH (NOLOCK)
RIGHT JOIN [CER].[CONOPS_CER_DAILY_TRUCK_DETAIL_V] [truck] WITH (NOLOCK)
	ON [pl].TRUCK = [truck].TruckID 
	AND [pl].SHIFTID = [truck].SHIFTID 
LEFT JOIN [dbo].LOOKUPS img WITH (NOLOCK)
	ON img.TableType = 'CONF'
	AND img.TableCode = 'IMGURL'

