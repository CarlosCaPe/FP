CREATE VIEW [MOR].[CONOPS_MOR_TP_AVG_PAYLOAD_V] AS

--select * from [mor].[CONOPS_MOR_TP_AVG_PAYLOAD_V] WITH (NOLOCK) where shiftflag = 'curr' ORDER BY shiftflag, siteflag, TRUCK
CREATE VIEW [mor].[CONOPS_MOR_TP_AVG_PAYLOAD_V] 
AS

WITH CTE AS (
SELECT
	SiteFlag,
	ShiftId,
	Truck,
	AVG(FieldTons) AS AVG_PAYLOAD
FROM mor.shift_load_detail_v
GROUP BY
	SiteFlag,
	ShiftId,
	Truck
) 

SELECT 
	shiftflag,
	[truck].siteflag,
	[truck].SHIFTINDEX,
	TRUCK,
	UPPER([truck].Operator) as Operator,
	CASE WHEN Truck.OperatorId IS NULL OR Truck.OperatorId = -1 
		THEN NULL
		ELSE concat(img.[value], RIGHT('0000000000' + truck.OperatorId, 10),'.jpg') END as OperatorImageURL, 
	[AVG_Payload],
	pt.PayloadTarget AS [Target],
	StatusName [Status],
	[truck].ReasonId,
	[truck].ReasonDesc,
	[truck].Location
FROM cte [pl] WITH (NOLOCK)
RIGHT JOIN [mor].[CONOPS_MOR_TRUCK_DETAIL_V] [truck] WITH (NOLOCK)
	ON [pl].TRUCK = [truck].TruckID 
	AND [pl].SHIFTID = [truck].SHIFTID 
LEFT JOIN dbo.PAYLOAD_TARGET pt WITH (NOLOCK) 
	ON [truck].siteflag = pt.Siteflag
LEFT JOIN [dbo].LOOKUPS img WITH (NOLOCK)
	ON img.TableType = 'CONF'
	AND img.TableCode = 'IMGURL'

