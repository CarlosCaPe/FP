CREATE VIEW [dbo].[CONOPS_EQMT_TRUCK_MATRIX_V] AS








-- SELECT * FROM [dbo].[CONOPS_EQ_DRILL_V] WITH (NOLOCK)
CREATE VIEW [dbo].[CONOPS_EQMT_TRUCK_MATRIX_V]
AS

SELECT [shiftflag]
	,[siteflag]
	,[ShiftId]
	,[TruckID]
	,[Operator]
	,[OperatorImageURL]
	,[StatusName]
	,[ReasonId]
	,[ReasonDesc]
	,[Payload]
	,[PayloadTarget]
	,[TotalMaterialDelivered]
	,[TotalMaterialDeliveredTarget]
	,[DeltaC]
	,[DeltaCTarget]
	,[IdleTime]
	,[IdleTimeTarget]
	,[Spotting]
	,[SpottingTarget]
	,[Loading]
	,[LoadingTarget]
	,[Dumping]
	,[DumpingTarget]
	,[DumpsAtStockpile]
	,[DumpsAtStockpileTarget]
	,[DumpsAtCrusher]
	,[DumpsAtCrusherTarget]
	,[Location]
	,[TonsHaul]
	,[TonsHaulTarget]
	,[Utilization]
	,[EmptyTravel]
	,[EmptyTravelTarget]
	,[duration]
	,[Score]
FROM [mor].[CONOPS_MOR_EQMT_TRUCK_MATRIX_V]
WHERE siteflag = 'MOR'


UNION ALL

SELECT [shiftflag]
	,[siteflag]
	,[ShiftId]
	,[TruckID]
	,[Operator]
	,[OperatorImageURL]
	,[StatusName]
	,[ReasonId]
	,[ReasonDesc]
	,[Payload]
	,[PayloadTarget]
	,[TotalMaterialDelivered]
	,[TotalMaterialDeliveredTarget]
	,[DeltaC]
	,[DeltaCTarget]
	,[IdleTime]
	,[IdleTimeTarget]
	,[Spotting]
	,[SpottingTarget]
	,[Loading]
	,[LoadingTarget]
	,[Dumping]
	,[DumpingTarget]
	,[DumpsAtStockpile]
	,[DumpsAtStockpileTarget]
	,[DumpsAtCrusher]
	,[DumpsAtCrusherTarget]
	,[Location]
	,[TonsHaul]
	,[TonsHaulTarget]
	,[Utilization]
	,[EmptyTravel]
	,[EmptyTravelTarget]
	,[duration]
	,[Score]
FROM [bag].[CONOPS_BAG_EQMT_TRUCK_MATRIX_V]
WHERE siteflag = 'BAG'


UNION ALL

SELECT [shiftflag]
	,[siteflag]
	,[ShiftId]
	,[TruckID]
	,[Operator]
	,[OperatorImageURL]
	,[StatusName]
	,[ReasonId]
	,[ReasonDesc]
	,[Payload]
	,[PayloadTarget]
	,[TotalMaterialDelivered]
	,[TotalMaterialDeliveredTarget]
	,[DeltaC]
	,[DeltaCTarget]
	,[IdleTime]
	,[IdleTimeTarget]
	,[Spotting]
	,[SpottingTarget]
	,[Loading]
	,[LoadingTarget]
	,[Dumping]
	,[DumpingTarget]
	,[DumpsAtStockpile]
	,[DumpsAtStockpileTarget]
	,[DumpsAtCrusher]
	,[DumpsAtCrusherTarget]
	,[Location]
	,[TonsHaul]
	,[TonsHaulTarget]
	,[Utilization]
	,[EmptyTravel]
	,[EmptyTravelTarget]
	,[duration]
	,[Score]
FROM [saf].[CONOPS_SAF_EQMT_TRUCK_MATRIX_V]
WHERE siteflag = 'SAF'


UNION ALL

SELECT [shiftflag]
	,[siteflag]
	,[ShiftId]
	,[TruckID]
	,[Operator]
	,[OperatorImageURL]
	,[StatusName]
	,[ReasonId]
	,[ReasonDesc]
	,[Payload]
	,[PayloadTarget]
	,[TotalMaterialDelivered]
	,[TotalMaterialDeliveredTarget]
	,[DeltaC]
	,[DeltaCTarget]
	,[IdleTime]
	,[IdleTimeTarget]
	,[Spotting]
	,[SpottingTarget]
	,[Loading]
	,[LoadingTarget]
	,[Dumping]
	,[DumpingTarget]
	,[DumpsAtStockpile]
	,[DumpsAtStockpileTarget]
	,[DumpsAtCrusher]
	,[DumpsAtCrusherTarget]
	,[Location]
	,[TonsHaul]
	,[TonsHaulTarget]
	,[Utilization]
	,[EmptyTravel]
	,[EmptyTravelTarget]
	,[duration]
	,[Score]
FROM [cer].[CONOPS_CER_EQMT_TRUCK_MATRIX_V]
WHERE siteflag = 'CER'


UNION ALL

SELECT [shiftflag]
	,[siteflag]
	,[ShiftId]
	,[TruckID]
	,[Operator]
	,[OperatorImageURL]
	,[StatusName]
	,[ReasonId]
	,[ReasonDesc]
	,[Payload]
	,[PayloadTarget]
	,[TotalMaterialDelivered]
	,[TotalMaterialDeliveredTarget]
	,[DeltaC]
	,[DeltaCTarget]
	,[IdleTime]
	,[IdleTimeTarget]
	,[Spotting]
	,[SpottingTarget]
	,[Loading]
	,[LoadingTarget]
	,[Dumping]
	,[DumpingTarget]
	,[DumpsAtStockpile]
	,[DumpsAtStockpileTarget]
	,[DumpsAtCrusher]
	,[DumpsAtCrusherTarget]
	,[Location]
	,[TonsHaul]
	,[TonsHaulTarget]
	,[Utilization]
	,[EmptyTravel]
	,[EmptyTravelTarget]
	,[duration]
	,[Score]
FROM [sie].[CONOPS_SIE_EQMT_TRUCK_MATRIX_V]
WHERE siteflag = 'SIE'


UNION ALL

SELECT [shiftflag]
	,[siteflag]
	,[ShiftId]
	,[TruckID]
	,[Operator]
	,[OperatorImageURL]
	,[StatusName]
	,[ReasonId]
	,[ReasonDesc]
	,[Payload]
	,[PayloadTarget]
	,[TotalMaterialDelivered]
	,[TotalMaterialDeliveredTarget]
	,[DeltaC]
	,[DeltaCTarget]
	,[IdleTime]
	,[IdleTimeTarget]
	,[Spotting]
	,[Spott