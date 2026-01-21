






/******************************************************************  
* PROCEDURE	: dbo.Equipment_Truck_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: mbote, 27 Feb 2023
* SAMPLE	: 
	1. EXEC dbo.Equipment_Truck_Get 'CURR', 'MOR'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {27 Feb 2023}		{mbote}		{Initial Created}
* {20 Oct 2023}		{lwasini}	{Add additional item}
* {12 Jan 2024}		{lwasini}	{Add TYR}
* {23 Jan 2024}     {lwasini}	{Add ABR}
* {18 Sep 2024}     {ggosal1}	{Add CycleEfficiency, AvgCycleTime, MinsOverExpected}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Equipment_Truck_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
	--@STATUS NVARCHAR(MAX)
)
AS                        
BEGIN      

	IF @SITE = 'BAG'
	BEGIN
		SELECT 
			[TruckID]
			,[StatusName] AS [status]
			,[Operator]
			,[OperatorImageURL]
			,[Location]
			,ROUND([Payload],0) [Payload]
			,[PayloadTarget]
			,ROUND([DeltaC],1) [DeltaC]
			,[DeltaCTarget]
			,ROUND([IdleTime],1) [IdleTime]
			,[IdleTimeTarget]
			,ROUND([Spotting],1) [Spotting]
			,[SpottingTarget]
			,ROUND([Loading],1) [Loading]
			,ROUND([LoadingTarget],1) [LoadingTarget]
			,ROUND(LoadedTravel,1) [LoadedTravel]
			,ROUND([LoadedTravelTarget],1) [LoadedTravelTarget]
			,ROUND([DumpsAtStockpile],1) [DumpsAtStockpile]
			,[DumpsAtStockpileTarget]
			,ROUND([DumpsAtCrusher],1) [DumpsAtCrusher]
			,[DumpsAtCrusherTarget]
			,ROUND([EmptyTravel],1) [EmptyTravel]
			,ROUND([EmptyTravelTarget],1) [EmptyTravelTarget]
			,TonsHaul
			,TonsHaulTarget
			,ROUND(UseofAvailability,0) [UseofAvailability]
			,[UseofAvailabilityTarget]
			,ROUND([Availability],0) [Availability]
			,AvailabilityTarget
			,EFH
			,EFHTarget
			,TonsMined
			,TonsMinedTarget
			,TonsMoved
			,TonsMovedTarget
			,CycleEfficiency
			,AvgCycleTime
			,MinsOverExpected
			,[ReasonId]
			,[ReasonDesc]
			,ROUND(TimeInState,2) [TimeInState]
			,'80' Score
		FROM [bag].[CONOPS_BAG_EQMT_TRUCK_V]
		WHERE shiftflag = @SHIFT
		--AND (StatusName IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER( @STATUS ), ',')) OR ISNULL( @STATUS, '') = '')
	END

	ELSE IF @SITE = 'CVE'
	BEGIN
		SELECT 
			[TruckID]
			,[StatusName] AS [status]
			,[Operator]
			,[OperatorImageURL]
			,[Location]
			,ROUND([Payload],0) [Payload]
			,[PayloadTarget]
			,ROUND([DeltaC],1) [DeltaC]
			,[DeltaCTarget]
			,ROUND([IdleTime],1) [IdleTime]
			,[IdleTimeTarget]
			,ROUND([Spotting],1) [Spotting]
			,[SpottingTarget]
			,ROUND([Loading],1) [Loading]
			,ROUND([LoadingTarget],1) [LoadingTarget]
			,ROUND(LoadedTravel,1) [LoadedTravel]
			,ROUND([LoadedTravelTarget],1) [LoadedTravelTarget]
			,ROUND([DumpsAtStockpile],1) [DumpsAtStockpile]
			,[DumpsAtStockpileTarget]
			,ROUND([DumpsAtCrusher],1) [DumpsAtCrusher]
			,[DumpsAtCrusherTarget]
			,ROUND([EmptyTravel],1) [EmptyTravel]
			,ROUND([EmptyTravelTarget],1) [EmptyTravelTarget]
			,TonsHaul
			,TonsHaulTarget
			,ROUND(UseofAvailability,0) [UseofAvailability]
			,[UseofAvailabilityTarget]
			,ROUND([Availability],0) [Availability]
			,AvailabilityTarget
			,EFH
			,EFHTarget
			,TonsMined
			,TonsMinedTarget
			,TonsMoved
			,TonsMovedTarget
			,CycleEfficiency
			,AvgCycleTime
			,MinsOverExpected
			,[ReasonId]
			,[ReasonDesc]
			,ROUND(TimeInState,2) [TimeInState]
			,'80' Score
		FROM [cer].[CONOPS_CER_EQMT_TRUCK_V]
		WHERE shiftflag = @SHIFT
		--AND (StatusName IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER( @STATUS ), ',')) OR ISNULL( @STATUS, '') = '')
	END

	ELSE IF @SITE = 'CHN'
	BEGIN
		SELECT 
			[TruckID]
			,[StatusName] AS [status]
			,[Operator]
			,[OperatorImageURL]
			,[Location]
			,ROUND([Payload],0) [Payload]
			,[PayloadTarget]
			,ROUND([DeltaC],1) [DeltaC]
			,[DeltaCTarget]
			,ROUND([IdleTime],1) [IdleTime]
			,[IdleTimeTarget]