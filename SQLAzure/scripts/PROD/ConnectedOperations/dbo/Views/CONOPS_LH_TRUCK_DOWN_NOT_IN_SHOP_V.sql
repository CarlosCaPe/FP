CREATE VIEW [dbo].[CONOPS_LH_TRUCK_DOWN_NOT_IN_SHOP_V] AS


CREATE VIEW [dbo].[CONOPS_LH_TRUCK_DOWN_NOT_IN_SHOP_V]
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
FROM [mor].[CONOPS_MOR_TRUCK_DOWN_NOT_IN_SHOP_V] WITH (NOLOCK)
WHERE siteflag = 'MOR'

UNION ALL

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
FROM [bag].[CONOPS_BAG_TRUCK_DOWN_NOT_IN_SHOP_V] WITH (NOLOCK)
WHERE siteflag = 'BAG'


