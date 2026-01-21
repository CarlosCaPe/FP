
/******************************************************************  
* PROCEDURE	: dbo.Operator_TruckDetail_HourlyData_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: mbote, 09 May 2023
* SAMPLE	: 
	1. EXEC dbo.Operator_TruckDetail_HourlyData_Get 'CURR', 'TYR', '60060684'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {18 May 2023}		{mbote}		{Initial Created}
* {23 Oct 2023}		{lwasini}	{Add Hourly Data}
* {22 Jan 2024}		{lwasini}	{Add TYR}
* {24 Jan 2024}		{lwasini}	{Add ABR}
* {08 May 2024}		{ggosal1}	{Remove divided by 1000}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Operator_TruckDetail_HourlyData_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@OPERID VARCHAR(50)
)
AS                        
BEGIN  

	SET @SITE = CASE @SITE
					WHEN 'SAM' THEN 'SAF'
					WHEN 'CVE' THEN 'CER'
					WHEN 'CHN' THEN 'CHI'
					ELSE @SITE
				END;

BEGIN TRY

	IF @SITE = 'BAG'
	BEGIN
		SELECT 
		  [TruckID]
		  ,[OperatorId]
		  ,[DeltaC]
		  ,[IdleTime]
		  ,[IdleTimeTarget]
		  ,[Spotting]
		  ,[SpottingTarget]
		  ,[Loading]
		  ,[LoadingTarget]
		  ,[LoadedTravel]
		  ,[LoadedTravelTarget]
		  ,[Dumping]
		  ,[DumpingTarget]
		  ,[DumpsAtStockpile]
		  ,[DumpsAtStockpileTarget]
		  ,[DumpsAtCrusher]
		  ,[DumpsAtCrusherTarget]
		  ,[EmptyTravel]
		  ,[EmptyTravelTarget]
		  ,[Htos]
		  ,[HtosTarget]
		  ,[TPRH]
		  ,[TPRHTarget]
		  ,[FirstHourTons]
		  ,NULL [FirstHourTonsTarget]
		  ,[LastHourTons]
		  ,NULL [LastHourTonsTarget]
		  ,[Efh]
		  ,[EfhTarget]
		  ,AvgUseOfAvailibility AS UseOfAvailability
		  ,AvgUseOfAvailibilityTarget AS UseOfAvailabilityTarget
		  ,TotalMaterialMoved AS TonsMoved
		  ,TotalMaterialMovedTarget AS TonsMovedTarget
		FROM [bag].[CONOPS_BAG_OPERATOR_TRUCK_DETAIL_DELTA_C_V] WITH (NOLOCK)
		WHERE ShiftFlag = @SHIFT
		AND OperatorId = @OPERID;

	
	END

	ELSE IF @SITE = 'CER'
	BEGIN
		SELECT 
		  [TruckID]
		  ,[OperatorId]
		  ,[DeltaC]
		  ,[IdleTime]
		  ,[IdleTimeTarget]
		  ,[Spotting]
		  ,[SpottingTarget]
		  ,[Loading]
		  ,[LoadingTarget]
		  ,[LoadedTravel]
		  ,[LoadedTravelTarget]
		  ,[Dumping]
		  ,[DumpingTarget]
		  ,[DumpsAtStockpile]
		  ,[DumpsAtStockpileTarget]
		  ,[DumpsAtCrusher]
		  ,[DumpsAtCrusherTarget]
		  ,[EmptyTravel]
		  ,[EmptyTravelTarget]
		  ,[Htos]
		  ,[HtosTarget]
		  ,[TPRH]
		  ,[TPRHTarget]
		  ,[FirstHourTons]
		  ,NULL [FirstHourTonsTarget]
		  ,[LastHourTons]
		  ,NULL [LastHourTonsTarget]
		  ,[Efh]
		  ,[EfhTarget]
		  ,AvgUseOfAvailibility AS UseOfAvailability
		  ,AvgUseOfAvailibilityTarget AS UseOfAvailabilityTarget
		  ,TotalMaterialMoved AS TonsMoved
		  ,TotalMaterialMovedTarget AS TonsMovedTarget
		FROM [cer].[CONOPS_CER_OPERATOR_TRUCK_DETAIL_DELTA_C_V] WITH (NOLOCK)
		WHERE ShiftFlag = @SHIFT
		AND OperatorId = @OPERID;

		
	END

	ELSE IF @SITE = 'CHI'
	BEGIN
		SELECT 
		  [TruckID]
		  ,[OperatorId]
		  ,[DeltaC]
		  ,[IdleTime]
		  ,[IdleTimeTarget]
		  ,[Spotting]
		  ,[SpottingTarget]
		  ,[Loading]
		  ,[LoadingTarget]
		  ,[LoadedTravel]
		  ,[LoadedTravelTarget]
		  ,[Dumping]
		  ,[DumpingTarget]
		  ,[DumpsAtStockpile]
		  ,[DumpsAtStockpileTarget]
		  ,[DumpsAtCrusher]
		  ,[DumpsAtCrusherTarget]
		  ,[EmptyTravel]
		  ,[EmptyTravelTarget]
		  ,[Htos]
		  ,[HtosTarget]
		  ,[TPRH]
		  ,[TPRHTarget]
		  ,[FirstHourTons]
		  ,NULL [FirstHourTonsTarget]
		  ,[LastHourTons]
		  ,NULL [LastHourTonsTarget]
		  ,[Efh]
		  ,[EfhTarget]
		  ,AvgUseOfAvailibility AS UseOfAvailability
		  ,AvgUseOfAvailibilityTarget AS UseOfAvailabilityTarget
		  ,TotalMaterialMoved AS TonsMoved
		  ,TotalMaterialMovedTarget AS TonsMovedTarget
		FROM [chi].[CONOPS_CHI_OPERATOR_TRUCK_DETAIL_DELTA_C_V] WITH (NOLOCK)
		WHERE ShiftFlag = @SHIFT
		AND OperatorId = @OPERID;

		
	END

	ELSE IF @SITE = 'CMX'