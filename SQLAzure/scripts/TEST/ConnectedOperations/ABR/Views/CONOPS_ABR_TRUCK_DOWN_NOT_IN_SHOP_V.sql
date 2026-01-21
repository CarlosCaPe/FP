CREATE VIEW [ABR].[CONOPS_ABR_TRUCK_DOWN_NOT_IN_SHOP_V] AS


-- SELECT * FROM [abr].[CONOPS_ABR_TRUCK_DOWN_NOT_IN_SHOP_V] WITH (NOLOCK)
CREATE VIEW [ABR].[CONOPS_ABR_TRUCK_DOWN_NOT_IN_SHOP_V] 
AS

SELECT shiftflag,
	   [siteflag],
	   TruckID,
	   Operator,
	   OperatorImageURL,
	   StatusStart,
	   ReasonId,
	   ReasonDesc,
	   Location,
	   Region
FROM (
	SELECT [t].SHIFTINDEX,
		   [t].shiftflag,
		   [t].siteflag,
		   TruckID,
		   [t].Operator,
		   [t].OperatorImageURL,
		   [t].StatusStart,
		   [t].ReasonId,
		   [t].ReasonDesc,
		   [t].Location,
		   [s].Region
	FROM [abr].[CONOPS_ABR_TRUCK_DETAIL_V] [t] WITH (NOLOCK)
	LEFT JOIN [abr].[CONOPS_ABR_SHOVEL_INFO_V] [s] WITH (NOLOCK)
	ON [t].shiftflag = [s].shiftflag AND [t].siteflag = [s].siteflag
	AND [t].AssignedShovel = [s].ShovelID
	WHERE [t].StatusCode = 1
	AND [t].Location NOT IN (
		SELECT Name
		FROM [abr].[CONOPS_ABR_TRUCK_SHOP_LOCATION_V] WITH (NOLOCK)
	)
) [TruckNotOnShop]


