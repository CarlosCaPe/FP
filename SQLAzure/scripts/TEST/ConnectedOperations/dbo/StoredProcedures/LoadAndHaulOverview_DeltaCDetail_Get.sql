








/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulOverview_DeltaCDetail_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 26 April 2023
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulOverview_DeltaCDetail_Get 'PREV', 'BAG'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {26 Apr 2023}		{lwasini}		{Initial Created} 
* {31 Aug 2023}		{ggosal1}		{Add Pit Name} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulOverview_DeltaCDetail_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN          
	
	IF @SITE = 'BAG'
	BEGIN

		SELECT
			PushBack AS Pit,
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
			EmptyTravel,
			EmptyTravelTarget,
			LoadedTravel,
			LoadedTravelTarget,
			DumpingAtStockpile,
			DumpingAtStockpileTarget,
			DumpingAtCrusher,
			DumpingAtCrusherTarget
		FROM [bag].[CONOPS_BAG_DELTA_C_DETAIL_V] 
		WHERE shiftflag = @SHIFT

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT 
			PushBack AS Pit,
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
			EmptyTravel,
			EmptyTravelTarget,
			LoadedTravel,
			LoadedTravelTarget,
			DumpingAtStockpile,
			DumpingAtStockpileTarget,
			DumpingAtCrusher,
			DumpingAtCrusherTarget
		FROM [cer].[CONOPS_CER_DELTA_C_DETAIL_V] 
		WHERE shiftflag = @SHIFT

	END

	ELSE IF @SITE = 'CHN'
	BEGIN

		SELECT 
			PushBack AS Pit,
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
			EmptyTravel,
			EmptyTravelTarget,
			LoadedTravel,
			LoadedTravelTarget,
			DumpingAtStockpile,
			DumpingAtStockpileTarget,
			DumpingAtCrusher,
			DumpingAtCrusherTarget
		FROM [chi].[CONOPS_CHI_DELTA_C_DETAIL_V] 
		WHERE shiftflag = @SHIFT

	END

	ELSE IF @SITE = 'CMX'
	BEGIN

		SELECT 
			PushBack AS Pit,
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
			EmptyTravel,
			EmptyTravelTarget,
			LoadedTravel,
			LoadedTravelTarget,
			DumpingAtStockpile,
			DumpingAtStockpileTarget,
			DumpingAtCrusher,
			DumpingAtCrusherTarget
		FROM [cli].[CONOPS_CLI_DELTA_C_DETAIL_V] 
		WHERE shiftflag = @SHIFT

	END

	ELSE IF @SITE = 'MOR'
	BEGIN

		SELECT 
			PushBack AS Pit,
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
			EmptyTravel,
			EmptyTravelTarget,
			LoadedTravel,
			LoadedTravelTarget,
			DumpingAtStockpile,
			DumpingAtStockpileTarget,
			DumpingAtCrusher,
			DumpingAtCrusherTarget
		FROM [mor].[CONOPS_MOR_DELTA_C_DETAIL_V] 
		WHERE shiftflag = @SHIFT

	END

	ELSE IF @SITE = 'SAM'
	BEGIN

		SELECT 
			PushBack AS Pit,
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
			EmptyTravel,
			EmptyTravelTarget,
			LoadedTravel,
			LoadedTravelTarget,
			DumpingAtStockpile,
			DumpingAtStockpileTarget,
			DumpingAtCrusher,
			DumpingAtCrusherTarget
		FROM [saf].[CONOPS_SAF_DELTA_C_DETAIL_V] 
		WHERE shiftflag = @SHIFT

	END

	ELSE IF @SITE = 'SIE'
	BEGIN

		SELECT 
			PushBack AS Pit,
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
			EmptyTravel,
			EmptyTravelTarget,
			LoadedTravel,
			LoadedTravelTa