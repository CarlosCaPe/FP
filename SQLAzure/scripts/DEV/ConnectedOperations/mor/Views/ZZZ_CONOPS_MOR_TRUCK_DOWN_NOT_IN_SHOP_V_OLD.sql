CREATE VIEW [mor].[ZZZ_CONOPS_MOR_TRUCK_DOWN_NOT_IN_SHOP_V_OLD] AS







-- SELECT * FROM [mor].[CONOPS_MOR_TRUCK_DOWN_NOT_IN_SHOP_V] WITH (NOLOCK)
CREATE VIEW [mor].[CONOPS_MOR_TRUCK_DOWN_NOT_IN_SHOP_V_OLD] 
AS

SELECT [shift].shiftflag,
	   [siteflag],
	   TruckID,
	   Operator,
	   OperatorImageURL,
	   StatusStart,
	   ReasonId,
	   ReasonDesc,
	   Location,
	   Region
FROM [mor].[CONOPS_MOR_SHIFT_INFO_V] [shift] WITH (NOLOCK)
LEFT JOIN (
	SELECT [t].SHIFTINDEX,
		   TruckID,
		   [t].Operator,
		   [t].OperatorImageURL,
		   [t].StatusStart,
		   [t].ReasonId,
		   [t].ReasonDesc,
		   [t].Location,
		   [s].Region
	FROM [mor].[CONOPS_MOR_TRUCK_DETAIL_V] [t] WITH (NOLOCK)
	LEFT JOIN [mor].[CONOPS_MOR_SHOVEL_INFO_V] [s] WITH (NOLOCK)
	ON [t].shiftflag = [s].shiftflag AND [t].siteflag = [s].siteflag
	AND [t].AssignedShovel = [s].ShovelID
	WHERE [t].StatusCode = 1
	AND [t].Location NOT IN (
		SELECT Name
		FROM [mor].[CONOPS_MOR_TRUCK_SHOP_LOCATION_V] WITH (NOLOCK)
	)
) [TruckNotOnShop]
on [TruckNotOnShop].SHIFTINDEX = [shift].ShiftIndex
WHERE [siteflag] = 'MOR'

