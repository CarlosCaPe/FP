CREATE VIEW [Arch].[CONOPS_TRUCK_POPUP_V] AS
CREATE VIEW [Arch].[CONOPS_TRUCK_POPUP_V]
AS

SELECT [t].shiftflag,
       [t].siteflag,
       TruckID,
       Operator,
       OperatorImageURL,
       StatusName,
       ReasonId,
       ReasonDesc,
       [Payload] AS [Payload],
       [PayloadTarget] AS [PayloadTarget],
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
       [ae].[use_of_availability_pct] AS AvgUseOfAvailibility,
       AvgUseOfAvailibilityTarget,
	   Location
FROM [Arch].[CONOPS_ARCH_TRUCK_POPUP_V] [t] WITH (NOLOCK)
LEFT JOIN [Arch].[CONOPS_TRUCK_ASSET_EFFICIENCY_PER_TRUCK_V] [ae] WITH (NOLOCK)
ON [t].shiftflag = [ae].shiftflag AND [t].siteflag = [ae].siteflag
   AND [t].TruckID = [ae].eqmt
