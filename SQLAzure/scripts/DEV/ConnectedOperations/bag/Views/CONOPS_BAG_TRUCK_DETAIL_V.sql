CREATE VIEW [bag].[CONOPS_BAG_TRUCK_DETAIL_V] AS






-- SELECT * FROM [bag].[CONOPS_BAG_TRUCK_DETAIL_V] WITH (NOLOCK) WHERE [shiftflag] = 'CURR' ORDER BY TruckID
CREATE VIEW [BAG].[CONOPS_BAG_TRUCK_DETAIL_V] 
AS

WITH EqAe AS(
SELECT
	SHIFTID,
	EQMT,
	EQMTTYPE,
	STATUSIDX AS StatusCode,
	STATUS AS StatusName,
	REASONIDX AS ReasonId,
	REASONS AS ReasonName,
	STARTDATETIME AS StatusStart,
	Duration,
	ROW_NUMBER() OVER (PARTITION BY SHIFTID, EQMT ORDER BY STARTDATETIME DESC) AS ROW_NO
FROM bag.ASSET_EFFICIENCY WITH(NOLOCK)
)

SELECT
s.shiftflag,
s.siteflag,
s.shiftid,
s.shiftindex,
p.EquipmentID AS TruckId,
e.EQMTTYPE,
e.StatusCode,
e.StatusName,
e.ReasonId,
e.ReasonName AS ReasonDesc,
e.StatusStart,
DATEDIFF(MINUTE, e.StatusStart, GETDATE()) AS TimeInState,
CONCAT('Crew', s.CrewID) AS CrewName,
p.Location,
NULL AS Region,
p.Operator,
p.OperatorId,
CASE WHEN p.OperatorId IS NULL OR p.OperatorId = -1 THEN NULL
	ELSE concat([img].Value, RIGHT('0000000000' + p.OperatorId, 10),'.jpg') 
	END as OperatorImageURL,
p.AssignedShovel,
s.ShiftDuration,
NULL AS Destination,
p.FieldX AS FieldXloc,
p.FieldY AS FieldYloc,
p.FieldZ AS FieldZ,
p.FieldVelocity
FROM BAG.FLEET_PIT_MACHINE_C p WITH (NOLOCK)
RIGHT JOIN BAG.CONOPS_BAG_SHIFT_INFO_V s
	ON p.SHIFTID = s.SHIFTID
LEFT JOIN EqAe e
	ON p.shiftid = e.SHIFTID
	AND p.EquipmentId = e.EQMT
	AND e.ROW_NO = 1
LEFT JOIN dbo.LOOKUPS [img] WITH (NOLOCK)
	ON [img].TableType = 'CONF' 
	AND [img].TableCode = 'IMGURL'
WHERE p.EquipmentCategory = 'Truck Classes'






