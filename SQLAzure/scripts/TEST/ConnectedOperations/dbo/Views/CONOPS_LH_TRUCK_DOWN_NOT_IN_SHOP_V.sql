CREATE VIEW [dbo].[CONOPS_LH_TRUCK_DOWN_NOT_IN_SHOP_V] AS


--select * from [dbo].[CONOPS_LH_TRUCK_DOWN_NOT_IN_SHOP_V] WITH (NOLOCK) where shiftflag = 'curr'
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
FROM [saf].[CONOPS_SAF_TRUCK_DOWN_NOT_IN_SHOP_V] WITH (NOLOCK)
WHERE siteflag = 'SAF'



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
FROM [sie].[CONOPS_SIE_TRUCK_DOWN_NOT_IN_SHOP_V] WITH (NOLOCK)
WHERE siteflag = 'SIE'


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
FROM [cli].[CONOPS_CLI_TRUCK_DOWN_NOT_IN_SHOP_V] WITH (NOLOCK)
WHERE siteflag = 'CMX'


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
FROM [cer].[CONOPS_CER_TRUCK_DOWN_NOT_IN_SHOP_V] WITH (NOLOCK)
WHERE siteflag = 'CER'

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
FROM [chi].[CONOPS_CHI_TRUCK_DOWN_NOT_IN_SHOP_V] WITH (NOLOCK)
WHERE siteflag = 'CHI'

