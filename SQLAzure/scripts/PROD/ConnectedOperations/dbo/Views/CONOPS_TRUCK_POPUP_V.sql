CREATE VIEW [dbo].[CONOPS_TRUCK_POPUP_V] AS


CREATE VIEW [dbo].[CONOPS_TRUCK_POPUP_V]
AS

SELECT [t].shiftflag,
       [t].siteflag,
       TruckID,
       Operator,
       OperatorImageURL,
       StatusName,
       ReasonId,
       ReasonDesc,
       [Payload],
       [PayloadTarget],
       [TotalMaterialDelivered] / 1000.00 AS [TotalMaterialDelivered],
       [TotalMaterialDeliveredTarget] / 1000.00 AS [TotalMaterialDeliveredTarget],
       DeltaC,
       DeltaCTarget,
       IdleTime,
       IdleTimeTarget,
       Spotting,
       SpottingTarget,
       Loading,
       LoadingTarget,
       Dumping,
       DumpingTarget,
       Efh,
       EfhTarget,
       [DumpsAtStockpile],
       DumpsAtStockpileTarget,
       DumpsAtCrusher,
       DumpsAtCrusherTarget,
       [ae].[use_of_availability] AS AvgUseOfAvailibility,
       AvgUseOfAvailibilityTarget,
	   Location
FROM [mor].[CONOPS_MOR_TRUCK_POPUP_V] [t] WITH (NOLOCK)
LEFT JOIN [dbo].[CONOPS_TRUCK_ASSET_EFFICIENCY_PER_TRUCK_V] [ae] WITH (NOLOCK)
ON [t].shiftflag = [ae].shiftflag AND [t].siteflag = [ae].siteflag
   AND [t].TruckID = [ae].eqmt
WHERE [t].siteflag = 'MOR'

UNION ALL

SELECT [t].shiftflag,
       [t].siteflag,
       TruckID,
       Operator,
       OperatorImageURL,
       StatusName,
       ReasonId,
       ReasonDesc,
       [Payload],
       [PayloadTarget],
       [TotalMaterialDelivered] / 1000.00 AS [TotalMaterialDelivered],
       [TotalMaterialDeliveredTarget] / 1000.00 AS [TotalMaterialDeliveredTarget],
       DeltaC,
       DeltaCTarget,
       IdleTime,
       IdleTimeTarget,
       Spotting,
       SpottingTarget,
       Loading,
       LoadingTarget,
       Dumping,
       DumpingTarget,
       Efh,
       EfhTarget,
       [DumpsAtStockpile],
       DumpsAtStockpileTarget,
       DumpsAtCrusher,
       DumpsAtCrusherTarget,
       [ae].[use_of_availability] AS AvgUseOfAvailibility,
       AvgUseOfAvailibilityTarget,
	   Location
FROM [bag].[CONOPS_BAG_TRUCK_POPUP_V] [t] WITH (NOLOCK)
LEFT JOIN [dbo].[CONOPS_TRUCK_ASSET_EFFICIENCY_PER_TRUCK_V] [ae] WITH (NOLOCK)
ON [t].shiftflag = [ae].shiftflag AND [t].siteflag = [ae].siteflag
   AND [t].TruckID = [ae].eqmt
WHERE [t].siteflag = 'BAG'


