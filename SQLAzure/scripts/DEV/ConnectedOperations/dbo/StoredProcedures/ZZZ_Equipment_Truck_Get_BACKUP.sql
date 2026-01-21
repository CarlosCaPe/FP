

/******************************************************************  
* PROCEDURE	: dbo.Equipment_Truck_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: mbote, 27 Feb 2023
* SAMPLE	: 
	1. EXEC dbo.Equipment_Truck_Get 'PREV', 'SIE', NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {27 Feb 2023}		{mbote}		{Initial Created}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Equipment_Truck_Get_BACKUP] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@STATUS NVARCHAR(MAX)
)
AS                        
BEGIN      

	IF @SITE = 'BAG'
	BEGIN
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
		AND siteflag = @SITE
		AND (StatusName IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER( @STATUS ), ',')) OR ISNULL( @STATUS, '') = '')
	END

	ELSE IF @SITE = 'CVE'
	BEGIN
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
		AND (StatusName IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER( @STATUS ), ',')) OR ISNULL( @STATUS, '') = '')
	END

	ELSE IF @SITE = 'CHN'
	BEGIN
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
		FROM [chi].[CONOPS_CHI_EQMT_TRUCK_V]
		WHERE shiftflag = @SHIFT
		AND (StatusName IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER( @STATUS ), ',')) OR ISNULL( @STATUS, '') = '')
	END

	ELSE IF @SITE = 'CMX'
	BEGIN
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
	