


/******************************************************************  
* PROCEDURE	: dbo.Operator_TruckDetail_HourlyData_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: mbote, 09 May 2023
* SAMPLE	: 
	1. EXEC dbo.Operator_TruckDetail_HourlyData_Get 'PREV', 'BAG', '61006665'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {18 May 2023}		{mbote}		{Initial Created}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[zzzz_Operator_TruckDetail_HourlyData_Get] 
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

	IF @SITE = 'BAG'
	BEGIN
		SELECT [ShiftFlag]
		  ,[SiteFlag]
		  ,[TruckID]
		  ,[ShiftId]
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
		FROM [bag].[CONOPS_BAG_OPERATOR_TRUCK_DETAIL_DELTA_C_V] WITH (NOLOCK)
		WHERE ShiftFlag = @SHIFT
		AND SiteFlag =  @SITE
		AND OperatorId = @OPERID;
		
		SELECT [ShiftFlag]
		  ,[SiteFlag]
		  ,[TruckID]
		  ,[ShiftId]
		  ,[OperatorId]
		  ,[Tprh]
		  ,[TprhTarget]
		  ,[TonsHauled]
		  ,[TonsHauledTarget]
		  ,[FirstHourTons]
		  ,[FirstHourTonsTarget]
		  ,[LastHourTons]
		  ,[LastHourTonsTarget]
		  ,[IdleAtCrushers]
		  ,[IdleAtCrushersTarget]
		  ,[TonsDelivered]
		  ,[TonsDeliveredTarget]
		  ,[ShiftChangeEff]
		  ,[ShiftChangeEffTarget]
		  ,[Efh]
		  ,[EfhTarget]
		FROM [bag].[CONOPS_BAG_OPERATOR_TRUCK_DETAIL_DELTA_C_V] WITH (NOLOCK)
		WHERE ShiftFlag = @SHIFT
		AND SiteFlag =  @SITE
		AND OperatorId = @OPERID;
		
	END

	ELSE IF @SITE = 'CER'
	BEGIN
		SELECT [ShiftFlag]
		  ,[SiteFlag]
		  ,[TruckID]
		  ,[ShiftId]
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
		FROM [cer].[CONOPS_CER_OPERATOR_TRUCK_DETAIL_DELTA_C_V] WITH (NOLOCK)
		WHERE ShiftFlag = @SHIFT
		AND SiteFlag =  @SITE
		AND OperatorId = @OPERID;

		SELECT [ShiftFlag]
		  ,[SiteFlag]
		  ,[TruckID]
		  ,[ShiftId]
		  ,[OperatorId]
		  ,[Tprh]
		  ,[TprhTarget]
		  ,[TonsHauled]
		  ,[TonsHauledTarget]
		  ,[FirstHourTons]
		  ,[FirstHourTonsTarget]
		  ,[LastHourTons]
		  ,[LastHourTonsTarget]
		  ,[IdleAtCrushers]
		  ,[IdleAtCrushersTarget]
		  ,[TonsDelivered]
		  ,[TonsDeliveredTarget]
		  ,[ShiftChangeEff]
		  ,[ShiftChangeEffTarget]
		  ,[Efh]
		  ,[EfhTarget]
		FROM [cer].[CONOPS_CER_OPERATOR_TRUCK_DETAIL_DELTA_C_V] WITH (NOLOCK)
		WHERE ShiftFlag = @SHIFT
		AND SiteFlag =  @SITE
		AND OperatorId = @OPERID;
	END

	ELSE IF @SITE = 'CHI'
	BEGIN
		SELECT [ShiftFlag]
		  ,[SiteFlag]
		  ,[TruckID]
		  ,[ShiftId]
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
		FROM [chi].[CONOPS_CHI_OPERATOR_TRUCK_DETAIL_DELTA_