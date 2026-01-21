CREATE VIEW [Arch].[CONOPS_LH_TRUCK_DOWN_NOT_IN_SHOP_V] AS
CREATE VIEW [Arch].[CONOPS_LH_TRUCK_DOWN_NOT_IN_SHOP_V]
AS

SELECT shiftflag,
	   siteflag,
	   TruckID,
	   Operator,
	   OperatorImageURL,
	   StatusStart,
	   ReasonId,
	   ReasonDesc,
	   Location,
	   Region
FROM [Arch].[CONOPS_ARCH_TRUCK_DOWN_NOT_IN_SHOP_V] WITH (NOLOCK)