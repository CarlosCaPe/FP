

/******************************************************************  
* PROCEDURE	: dbo.Equipment_Truck_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: mbote, 27 Feb 2023
* SAMPLE	: 
	1. EXEC dbo.Equipment_TruckDrillDown_Get 'PREV', 'MOR', 'READY', 'T500'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {15 March 2023}		{mbote}		{Initial Created}}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Equipment_TruckDrillDown_Get_BACKUP] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@STATUS VARCHAR(MAX),
	@TRUCK NVARCHAR(MAX)
)
AS                        
BEGIN   

	IF @SITE = 'BAG'
	BEGIN
		SELECT [shiftflag]
			,[siteflag]
			,[Equipment]
			,[Hr]
			,[Ae]
		FROM [bag].[CONOPS_BAG_HOURLY_TRUCK_ASSET_EFFICIENCY_V] WITH (NOLOCK)
		WHERE shiftflag =  @SHIFT
		AND [Equipment] = @TRUCK
		AND [EqmtUnit] = 1

		SELECT [shiftflag]
			,[siteflag]
			,[ShiftId]
			,[TruckID]
			,[Operator]
			,[OperatorImageURL]
			,[StatusName] AS [status]
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
		FROM [bag].[CONOPS_BAG_EQMT_TRUCK_V]
		WHERE shiftflag = @SHIFT
		AND (StatusName IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER( @STATUS ), ',')) OR ISNULL(@STATUS, '') = '') 
		AND [TruckID] = @TRUCK
	END

	ELSE IF @SITE = 'CVE'
	BEGIN
		SELECT [shiftflag]
			,[siteflag]
			,[Equipment]
			,[Hr]
			,[Ae]
		FROM [cer].[CONOPS_CER_HOURLY_TRUCK_ASSET_EFFICIENCY_V] WITH (NOLOCK)
		WHERE shiftflag =  @SHIFT
		AND [Equipment] = @TRUCK
		AND [EqmtUnit] = 1

		SELECT [shiftflag]
			,[siteflag]
			,[ShiftId]
			,[TruckID]
			,[Operator]
			,[OperatorImageURL]
			,[StatusName] AS [status]
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
		FROM [cer].[CONOPS_CER_EQMT_TRUCK_V]
		WHERE shiftflag = @SHIFT
		AND (StatusName IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER( @STATUS ), ',')) OR ISNULL(@STATUS, '') = '') 
		AND [TruckID] = @TRUCK
	END

	ELSE IF @SITE = 'CHN'
	BEGIN
		SELECT [shiftflag]
			,[siteflag]
			,[Equipment]
			,[Hr]
			,[Ae]
		FROM [chi].[CONOPS_CHI_HOURLY_TRUCK_ASSET_EFFICIENCY_V] WITH (NOLOCK)
		WHERE shiftflag =  @SHIFT
		AND [Equipment] = @TRUCK
		AND [EqmtUnit] = 1

		SELECT [shiftflag]
			,[siteflag]
			,[ShiftId]
			,[TruckID]
			,[Operator]
			,[OperatorImageURL]
			,[StatusName] AS [status]
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
		FROM [chi].[CO